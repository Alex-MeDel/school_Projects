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

echo "===== RHEL Bootstrap Complete! ====="