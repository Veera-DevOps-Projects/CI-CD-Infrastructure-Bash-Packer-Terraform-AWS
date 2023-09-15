#!/bin/bash

# Backup and modify sysctl.conf for system configuration
sudo cp ../../etc/sysctl.conf ../../root/sysctl.conf_backup  # Backup sysctl.conf
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

# Download and install PostgreSQL
sudo wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
sudo apt-get install postgresql postgresql-contrib -y

# Modify PostgreSQL configuration to allow remote connections
sudo chmod 777 ~/../../etc/postgresql/14/main/postgresql.conf
sudo sed -i '1,/#listen_addresses/s/#listen_addresses/listen_addresses/g' ~/../../etc/postgresql/14/main/postgresql.conf
sudo sed -i '1,/localhost/s/localhost/*/g' ~/../../etc/postgresql/14/main/postgresql.conf

# Enable and start PostgreSQL service
sudo systemctl enable postgresql.service
sudo systemctl start postgresql.service

# Change the password for the 'postgres' user and set up SonarQube databases and users
echo "postgres:admin@2023" | sudo chpasswd
sudo runuser -l postgres -c "createuser sonar"
sudo -i -u postgres psql -c "ALTER USER sonar WITH ENCRYPTED PASSWORD 'sonar.admin@2023';"
sudo -i -u postgres psql -c "CREATE DATABASE sonarqube OWNER sonar;"
sudo -i -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE sonarqube to sonar;"

# Restart PostgreSQL service
sudo systemctl restart postgresql

# Uncomment the following line to reboot the system
# sudo reboot
