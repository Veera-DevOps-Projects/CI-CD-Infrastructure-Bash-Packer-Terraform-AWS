#!/bin/bash
# This script configures PostgreSQL's pg_hba.conf file and restarts the PostgreSQL service.

# Grant full read, write, and execute permissions (777) to pg_hba.conf.
sudo chmod 777 /etc/postgresql/14/main/pg_hba.conf

# Append a comment to describe the following rules.
echo '# IPv4 remote connections:' >> /etc/postgresql/14/main/pg_hba.conf

# Add host-based authentication rules to allow access from specific IP ranges.
echo 'host    all             all             10.0.3.0/24               scram-sha-256' >> /etc/postgresql/14/main/pg_hba.conf
echo 'host    all             all             10.0.4.0/24               scram-sha-256' >> /etc/postgresql/14/main/pg_hba.conf

# Restart the PostgreSQL service to apply the configuration changes.
sudo systemctl restart postgresql.service
