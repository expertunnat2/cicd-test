# Demo website

This repository contains a minimal demo static website you can host on an EC2 instance with httpd (Apache).

Files added:
- index.html
- styles.css
- deploy_to_ec2.sh  (script to copy files to your EC2 host)

Quick deploy (example):
1. Make the deploy script executable:
   chmod +x deploy_to_ec2.sh

2. Run the script (replace values):
   ./deploy_to_ec2.sh ec2-54-12-34-56.compute-1.amazonaws.com ec2-user /var/www/html ~/.ssh/my-ec2-key.pem

Notes:
- The script uses scp/ssh; it copies files to /tmp/website_deploy on the instance and then moves them to the target path with sudo.
- Ensure the SSH key has correct permissions (chmod 600) and the EC2 user can sudo.
- If your web server user is different (www-data or apache), the script attempts to chown files to a common user.
- If SELinux is enabled, you may need to restore SELinux contexts on the target files (e.g. sudo restorecon -Rv /var/www/html).
- Alternatively, you can manually copy the files:
  scp -i ~/.ssh/my-ec2-key.pem index.html styles.css ec2-user@your-ec2-host:/var/www/html/
