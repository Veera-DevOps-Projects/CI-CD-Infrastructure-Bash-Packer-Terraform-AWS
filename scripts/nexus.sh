#!/bin/bash
# This is a bash shell script for installing and configuring Nexus server.

# Install Java 8 and wget using yum package manager.
sudo yum install java-1.8.0-openjdk.x86_64 wget -y

# Create the installation directory for Nexus.
sudo mkdir -p /opt/nexus/

# Create a temporary working directory.
sudo mkdir -p /tmp/nexus/

# Change the current directory to the temporary working directory.
cd /tmp/nexus/

# Define the URL from which the Nexus distribution will be downloaded.
NEXUSURL="https://download.sonatype.com/nexus/3/nexus-3.45.0-01-unix.tar.gz"

# Download the Nexus distribution and save it as nexus.tar.gz.
sudo wget $NEXUSURL -O nexus.tar.gz

# Extract the Nexus distribution.
EXTOUT=$(`sudo tar -xzvf nexus.tar.gz`)

# Extract the top-level directory created during extraction.
NEXUSDIR=$(`echo $EXTOUT | cut -d '/' -f1`)

# Remove the downloaded archive to clean up.
sudo rm -rf /tmp/nexus/nexus.tar.gz

# Copy the Nexus distribution to the installation directory.
sudo rsync -avzh /tmp/nexus/ /opt/nexus/

# Create a system user named 'nexus' for running Nexus.
sudo useradd nexus

# Change the ownership of the Nexus installation directory to the 'nexus' user and group.
sudo chown -R nexus.nexus /opt/nexus

# Create a systemd service unit file for Nexus
NEXUS_SERVICE_FILE="/etc/systemd/system/nexus.service"

# Create a systemd service unit file for Nexus.
sudo touch $NEXUS_SERVICE_FILE


# Make the service unit file writable.
sudo chmod 644 $NEXUS_SERVICE_FILE

# Define the contents of the Nexus systemd service unit file.
cat <<EOT | sudo tee $NEXUS_SERVICE_FILE > /dev/null
[Unit]
Description=Nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/$NEXUSDIR/bin/nexus start
ExecStop=/opt/nexus/$NEXUSDIR/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOT

NEXUS_RC_FILE="/opt/nexus/$NEXUSDIR/bin/nexus.rc"

# Configure Nexus to run as the 'nexus' user.
echo 'run_as_user="nexus"' | sudo tee $NEXUS_RC_FILE > /dev/null

# Reload systemd to recognize the new service unit.
sudo systemctl daemon-reload

# Start the Nexus service.
sudo systemctl start nexus

# Enable the Nexus service to start automatically at system boot.
sudo systemctl enable nexus
