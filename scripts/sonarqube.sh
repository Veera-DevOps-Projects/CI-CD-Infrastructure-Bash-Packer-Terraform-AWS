#!/bin/bash

# Backup and modify sysctl.conf for system configuration
sudo cp ~/../../etc/sysctl.conf ../../root/sysctl.conf_backup  # Backup sysctl.conf
sudo chmod 777 ~/../../etc/sysctl.conf  # Give permissions to edit sysctl.conf

# Append custom system configurations to sysctl.conf
cat <<EOT>> ~/../../etc/sysctl.conf
vm.max_map_count=262144
fs.file-max=65536
ulimit -n 65536
ulimit -u 4096
EOT

# Backup and modify limits.conf for user resource limits
sudo cp /etc/security/limits.conf /root/sec_limit.conf_backup  # Backup limits.conf
sudo chmod 777 ~/../../etc/security/limits.conf  # Give permissions to edit limits.conf

# Append custom user resource limits to limits.conf
cat <<EOT> ~/../../etc/security/limits.conf
sonarqube   -   nofile   65536
sonarqube   -   nproc    409
EOT

# Update system packages and dependencies
sudo apt-get update -y

# Download and extract OpenJDK for SonarQube
sudo wget https://builds.openlogic.com/downloadJDK/openlogic-openjdk/11.0.18+10/openlogic-openjdk-11.0.18+10-linux-x64.tar.gz
tar -xvf openlogic-openjdk-11.0.18+10-linux-x64.tar.gz
sudo mkdir -p /usr/lib/jvm/openjdk-11.0.18/
sudo mv openlogic-openjdk-11.0.18+10-linux-x64/* /usr/lib/jvm/openjdk-11.0.18/
sudo chmod 777 ~/../../etc/environment  # Give permissions to edit environment file

# Append JAVA_HOME environment variable to environment file
cat <<EOT>> ~/../../etc/environment
JAVA_HOME="/usr/lib/jvm/openjdk-11.0.18/bin"
EOT

# Set JAVA_HOME environment variable
export JAVA_HOME=/usr/lib/jvm/openjdk-11.0.18/bin

# Reload environment variables from the updated environment file
. ~/../../etc/environment

# Set alternatives for Java and Java Compiler
sudo update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/openjdk-11.0.18/bin/java" 0
sudo update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/openjdk-11.0.18/bin/javac" 0
sudo update-alternatives --set java /usr/lib/jvm/openjdk-11.0.18/bin/java
sudo update-alternatives --set javac /usr/lib/jvm/openjdk-11.0.18/bin/javac

# Verify Java version
java -version

# Update system packages again
sudo apt-get update -y

# Download and install SonarQube
sudo mkdir -p /sonarqube/
cd /sonarqube/
sudo curl -O https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-8.3.0.34182.zip
sudo apt-get install zip -y
sudo unzip -o sonarqube-8.3.0.34182.zip -d /opt/
sudo mv /opt/sonarqube-8.3.0.34182/ /opt/sonarqube

# Create a SonarQube group and user
sudo groupadd sonar
sudo useradd -c "SonarQube - User" -d /opt/sonarqube/ -g sonar sonar
sudo chown sonar:sonar /opt/sonarqube/ -R

# Backup and modify SonarQube properties file
sudo cp /opt/sonarqube/conf/sonar.properties /root/sonar.properties_backup  # Backup sonar.properties
sudo chmod 777 ~/../../opt/sonarqube/conf/sonar.properties  # Give permissions to edit sonar.properties

# Append custom configurations to sonar.properties
cat <<EOT> ~/../../opt/sonarqube/conf/sonar.properties
sonar.jdbc.username=sonar
sonar.jdbc.password=sonar.admin@2023
sonar.jdbc.url=jdbc:postgresql://localhost:5432/sonarqube
#sonar.web.host=0.0.0.0
#sonar.web.port=9000
#sonar.web.javaAdditionalOpts=-server
sonar.search.javaOpts=-Xmx512m -Xms512m -XX:+HeapDumpOnOutOfMemoryError
#sonar.log.level=INFO
#sonar.path.logs=logs
EOT

# Create and configure systemd service for SonarQube
sudo touch ~/../../etc/systemd/system/sonarqube.service
sudo chmod 777 ~/../../etc/systemd/system/sonarqube.service

# Define systemd service unit for SonarQube
cat <<EOT> ~/../../etc/systemd/system/sonarqube.service
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=sonar
Group=sonar
Restart=always
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOT

# Reload systemd to recognize the new service
sudo systemctl daemon-reload

# Enable SonarQube service to start on boot
sudo systemctl enable sonarqube.service

# Uncomment the following lines to start and check the status of the SonarQube service
# sudo systemctl start sonarqube.service
# sudo systemctl status -l sonarqube.service

# Update system packages once again
sudo apt-get update -y

# Install Nginx and configure for SonarQube
sudo apt-get install nginx -y

# Remove the default Nginx configuration
sudo rm -rf ~/../../etc/nginx/sites-enabled/default
sudo rm -rf ~/../../etc/nginx/sites-available/default

# Create and configure Nginx site configuration for SonarQube
sudo touch ~/../../etc/nginx/sites-enabled/sonarqube.conf
sudo chmod 777 ~/../../etc/nginx/sites-enabled/sonarqube.conf

cat <<EOT> ~/../../etc/nginx/sites-enabled/sonarqube.conf
server {
    listen      80;
    # server_name sonarqube.groophy.in;
    access_log  /var/log/nginx/sonar.access.log;
    error_log   /var/log/nginx/sonar.error.log;
    proxy_buffers 16 64k;
    proxy_buffer_size 128k;
    location / {
        proxy_pass  http://127.0.0.1:9000;
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
        proxy_redirect off;
              
        proxy_set_header    Host            \$host;
        proxy_set_header    X-Real-IP       \$remote_addr;
        proxy_set_header    X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Proto http;
    }
}
EOT

# Create a symbolic link for the Nginx site configuration
sudo ln -s ~/../../etc/nginx/sites-enabled/sonarqube.conf /etc/nginx/sites-available/sonarqube.conf

# Enable Nginx service to start on boot
sudo systemctl enable nginx.service

# Uncomment the following line to restart Nginx service
# sudo systemctl restart nginx.service

# Allow necessary ports through the firewall
sudo ufw allow 80,9000,9001/tcp

# Uncomment the following lines to schedule a system reboot
# echo "System reboot in 30 sec"
# sleep 30
# sudo reboot
