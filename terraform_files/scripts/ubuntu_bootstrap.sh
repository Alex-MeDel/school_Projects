#!/bin/bash
# ==========================================
# UBUNTU BOOTSTRAP: Management & VPN Server
# ==========================================

# 1. Set up logging for Terraform/AWS debugging
# You can view this on the server at /var/log/bootstrap.log
exec > /var/log/bootstrap.log 2>&1
echo "Starting Ubuntu Bootstrap Process..."

# 2. Update System & Install Core Dependencies
apt-get update -y
apt-get install -y awscli chrony openvpn easy-rsa

# 3. NTP Configuration (Amazon Time Sync Service)
# Fulfills the "NTP (trusted servers)" requirement
echo "Configuring Amazon Time Sync..."
echo "server 169.254.169.123 prefer iburst minpoll 4 maxpoll 4" >> /etc/chrony/chrony.conf
systemctl restart chrony
systemctl enable chrony

# 4. OS-Level Domain Lockdown Fallback
# Fulfills "Locks down unauthorized domains" locally if AWS Route 53 Firewall is blocked by the Academy lab
echo "Configuring local DNS lockdown..."
echo "127.0.0.1 malware.local" >> /etc/hosts
echo "127.0.0.1 evil.local" >> /etc/hosts
echo "127.0.0.1 veryevil.local" >> /etc/hosts

# 5. OpenVPN & Certificate-Based Privacy
# Fulfills "Certificate-based privacy" and "Uses VPNs as appropriate"
echo "Initializing PKI and OpenVPN Certificates..."

# Create a directory for the Certificate Authority (CA)
make-cadir /etc/openvpn/easy-rsa
cd /etc/openvpn/easy-rsa

# Initialize the Public Key Infrastructure (PKI)
./easyrsa init-pki

# Build the Certificate Authority (Batch mode prevents interactive prompts)
EASYRSA_BATCH=1 ./easyrsa build-ca nopass

# Generate the Server Certificate and Key
EASYRSA_BATCH=1 ./easyrsa gen-req server nopass
EASYRSA_BATCH=1 ./easyrsa sign-req server server

# Generate Diffie-Hellman parameters (Required for OpenVPN encryption)
./easyrsa gen-dh

# Generate a Client Certificate (For testing/accessing the VPN later)
EASYRSA_BATCH=1 ./easyrsa gen-req client1 nopass
EASYRSA_BATCH=1 ./easyrsa sign-req client client1

# Move generated keys and certs to the OpenVPN directory
cp pki/ca.crt pki/private/server.key pki/issued/server.crt pki/dh.pem /etc/openvpn/

# 6. OpenVPN Server Configuration
echo "Writing OpenVPN server.conf..."
cat <<EOF > /etc/openvpn/server.conf
port 1194
proto udp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh.pem
server 10.8.0.0 255.255.255.0
push "route 10.0.0.0 255.255.0.0" # Route traffic to your VPC CIDR
keepalive 10 120
cipher AES-256-GCM
persist-key
persist-tun
status openvpn-status.log
verb 3
EOF

# Start and enable the OpenVPN service
systemctl start openvpn@server
systemctl enable openvpn@server

# 7. Enable IP Forwarding
# Absolutely critical: allows the VPN server to route traffic into the private subnet
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

# 8. S3 Integration Verification
# This uses the dynamic Terraform variable to verify access to your bootstrap bucket
echo "Verifying access to Terraform S3 Bootstrap Bucket: ${bucket_name}"
aws s3 ls s3://${bucket_name}/ >> /var/log/bootstrap_s3_check.txt

echo "Ubuntu Bootstrap Complete!"