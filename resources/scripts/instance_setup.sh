#!/bin/bash

printf "Beginning user data script.\n"

#################################
# --- Environment Variables --- #
#################################

WORDPRESS_SLUG="${WORDPRESS_SLUG}"
DB_NAME="${DB_NAME}"
DB_USER="${DB_USER}"
DB_PASSWORD_SSM_PARAM="${DB_PASSWORD_SSM_PARAM}"
DB_HOST="${DB_HOST}"
EFS_IP="${EFS_IP}"
REGION="${REGION}"

##############################
# --- EC2 Instance Setup --- #
##############################

# Update the EC2 Instance
sudo yum update -y
# Install PHP
sudo amazon-linux-extras install -y php7.4
# Install HTTPD, NFS, EFS, PHP Graphics Library
sudo yum install -y httpd nfs-utils amazon-efs-utils php-gd php-xml php-mbstring php-imagick
# Enable the HTTPD Server on boot
sudo systemctl enable httpd
# Make the EFS Directory
mkdir /efs
# Mount the EFS Directory
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport $EFS_IP:/ /efs
# Install the CloudWatch Logging Agent
sudo yum install amazon-cloudwatch-agent -y
# Get the CloudWatch Config File
aws --region $REGION ssm get-parameter --name $CW_CONFIG_SSM_PARAM --output text --query Parameter.Value > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
# Start CloudWatch Agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

###########################
# --- Wordpress Setup --- #
###########################

# Check if Wordpress already exists
if [ ! -d "/efs/$WORDPRESS_SLUG" ]
then

  echo "Wordpress does not already exist in the provided directory. Setting up Wordpress."

  # Make the directory in NFS
  mkdir /efs/$WORDPRESS_SLUG
  # Link the directory to the httpd directory
  rm -rf /var/www/html
  ln -s /efs/$WORDPRESS_SLUG /var/www/html

  # Create the Wordpress directory and move to it
  mkdir /tmp/wordpress && cd /tmp/wordpress

  # Get the latest Wordpress installer and unzip it
  wget https://wordpress.org/latest.tar.gz && tar -xzf latest.tar.gz

  # Copy the wordpress config file
  cp wordpress/wp-config-sample.php wordpress/wp-config.php

  # Get the database password
  DB_PASSWORD=$(aws --region $REGION ssm get-parameter --name $DB_PASSWORD_SSM_PARAM --with-decryption --output text --query Parameter.Value)

  printf "\nif (!empty($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') { $_SERVER['HTTPS'] = 'on'; }\n" >> wordpress/wp-config.php

  # Find and replace the database details
  perl -pi -e "s/database_name_here/$DB_NAME/g" wordpress/wp-config.php
  perl -pi -e "s/username_here/$DB_USER/g" wordpress/wp-config.php
  perl -pi -e "s/password_here/$DB_PASSWORD/g" wordpress/wp-config.php
  perl -pi -e "s/localhost/$DB_HOST/g" wordpress/wp-config.php

  # Setup the Wordpress Salts
  perl -i -pe'
    BEGIN {
      @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
      push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
      sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
    }
    s/put your unique phrase here/salt()/ge
  ' wordpress/wp-config.php

  cp -r wordpress/* /var/www/html/

else
  echo "Wordpress does already exist in the directory. Skipping Wordpress setup."
  # Link the directory to the httpd directory
  rm -rf /var/www/html
  ln -s /efs/$WORDPRESS_SLUG /var/www/html
fi

########################
# --- Apache Setup --- #
########################

# Allow Permalinks
sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/ s/AllowOverride None/AllowOverride all/' /etc/httpd/conf/httpd.conf
# Disable Directory Listing
sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/ s/Options Indexes FollowSymLinks/Options FollowSymLinks/' /etc/httpd/conf/httpd.conf
# Turn Server Signatures and Server Tokens to the correct settings for prod
printf "ServerSignature Off\nServerTokens Prod\n" >> /etc/httpd/conf/httpd.conf
# Add the current user to the Apache group
sudo usermod -a -G apache ec2-user
# Make the apache group own /var/www
sudo chown -R ec2-user:apache /var/www/html
# Add group write permissions
sudo chmod 2775 /var/www/html
# Add write permissions to sub directories
find /var/www/html -type d -exec chmod 2775 {} \;
# Add write permissions to sub files
find /var/www/html -type f -exec chmod 0664 {} \;
# Start the Server
sudo systemctl start httpd

printf "Ending user data script.\n"
