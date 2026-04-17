#!/bin/bash

# ==========================================
# RHEL BOOTSTRAP: Database Server
# ==========================================

# 1. Set up logging for Terraform/AWS debugging
exec > /var/log/bootstrap.log 2>&1
echo "Starting RHEL Bootstrap Process..."

# 2. Update System & Install Core Dependencies
# Note: RHEL uses dnf instead of apt
dnf update -y
dnf install -y chrony postgresql-server postgresql-contrib awscli

# 3. NTP Configuration (Amazon Time Sync Service)
# Fulfills the "NTP (trusted servers)" requirement
# Essentially copy pasted this area from ubuntu_bootstap.sh
echo "Configuring Amazon Time Sync..."
echo "server 169.254.169.123 prefer iburst minpoll 4 maxpoll 4" >> /etc/chrony.conf
systemctl restart chronyd
systemctl enable chronyd

# 4. OS-Level Domain Lockdown Fallback
# Fulfills "Locks down unauthorized domains" locally
echo "Configuring local DNS lockdown..."
echo "127.0.0.1 malware.local" >> /etc/hosts
echo "127.0.0.1 evil.local" >> /etc/hosts
echo "127.0.0.1 veryevil.local" >> /etc/hosts

# 5. Database Setup (PostgreSQL)
# Fulfills "A database (SQL or Oracle)" requirement
echo "Initializing PostgreSQL Database..."

# RHEL requires you to manually initialize the database cluster first
postgresql-setup --initdb

# Google Gemini AI, helped in the configuration of Postgres
# By default, Postgres only listens to localhost. We need to tell it to listen to the network.
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /var/lib/pgsql/data/postgresql.conf

# Allow password authentication from the entire VPC CIDR (10.0.0.0/16)
# This allows your Ubuntu Management server to actually query the database
echo "host    all             all             10.0.0.0/16             md5" >> /var/lib/pgsql/data/pg_hba.conf

# Start and enable the database service
systemctl start postgresql
systemctl enable postgresql

# 6. Create a default Database and Admin User
# This proves that the database is fully operational
echo "Creating dummy database and user..."
sudo -u postgres psql -c "CREATE USER dbadmin WITH PASSWORD 'AcademyPassw0rd!';"
sudo -u postgres psql -c "CREATE DATABASE appdb OWNER dbadmin;"

# 7. Third-Party Vendor Access Provisioning
# Fulfills "Allows for third party agreements" requirement
echo "Provisioning scoped third-party access (Database Contractor)..."

# Create the user with a home directory and bash shell
useradd -m -s /bin/bash vendor_dbadmin

# Setup the SSH directory structure
mkdir -p /home/vendor_dbadmin/.ssh

# Inject a different dummy public key for this specific vendor
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQC_DUMMY_KEY_FOR_VENDOR_DB_ vendor_dbadmin" > /home/vendor_dbadmin/.ssh/authorized_keys

# Lock down permissions
chmod 700 /home/vendor_dbadmin/.ssh
chmod 600 /home/vendor_dbadmin/.ssh/authorized_keys
chown -R vendor_dbadmin:vendor_dbadmin /home/vendor_dbadmin/.ssh

# 8. OS-Level Program Lockdown (SELinux)
# Fulfills "Locks down unauthorized programs" requirement
echo "Verifying and Enforcing SELinux Policies..."

# Force SELinux into enforcing mode dynamically
setenforce 1

# Make the change permanent across reboots by modifying the config file
sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config

# Output the status to the log file as proof of implementation
echo "--- SELinux Status ---" >> /var/log/bootstrap.log
sestatus >> /var/log/bootstrap.log
echo "----------------------" >> /var/log/bootstrap.log

# 9. Simulate On-Premises Data Migration
# Fulfills "Securely migrated on premises data to the cloud environment" requirement
echo "Migrating legacy on-premises data into PostgreSQL..."

# Create a mock table and insert records into the 'appdb' database
sudo -u postgres psql -d appdb -c "
CREATE TABLE legacy_inventory (
    id SERIAL PRIMARY KEY,
    hostname VARCHAR(50),
    os_version VARCHAR(50),
    status VARCHAR(20)
);
INSERT INTO legacy_inventory (hostname, os_version, status) VALUES
    ('onprem-dc01', 'Windows Server 2012', 'Decommissioned'),
    ('onprem-db01', 'RHEL 7', 'Migrated'),
    ('onprem-web01', 'Ubuntu 18.04', 'Migrated');
"

# Output the migrated data to the bootstrap log to prove it exists
echo "--- Migrated Data Verification ---" >> /var/log/bootstrap.log
sudo -u postgres psql -d appdb -c "SELECT * FROM legacy_inventory;" >> /var/log/bootstrap.log
echo "----------------------------------" >> /var/log/bootstrap.log

echo "===== RHEL Bootstrap Complete! ====="