#!/bin/bash
set -e

echo "Starting EC2 deployment via CodePipeline + SSM"

TARGET_DIR="/var/www/html"

sudo mkdir -p $TARGET_DIR

sudo cp index.html styles.css $TARGET_DIR/

sudo chown -R apache:apache $TARGET_DIR || true
sudo chown -R www-data:www-data $TARGET_DIR || true

echo "DEPLOY SUCCESS $(date)" | sudo tee $TARGET_DIR/deploy.txt
