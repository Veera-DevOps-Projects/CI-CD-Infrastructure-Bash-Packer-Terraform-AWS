#!/bin/bash
# This script modifies the SonarQube configuration file to replace 'localhost' with the provided 'postgres_host' and restarts the SonarQube service.

# Using 'sed' to perform an in-place substitution in the SonarQube configuration file.
# The '1,/localhost/' ensures that only the first occurrence of 'localhost' is replaced.
# The 's/localhost/${postgres_host}/g' replaces 'localhost' with the 'postgres_host' variable throughout the file.
sed -i '1,/localhost/s/localhost/${postgres_host}/g' /opt/sonarqube/conf/sonar.properties

# Restart the SonarQube service to apply the configuration changes.
sudo systemctl restart sonarqube.service
