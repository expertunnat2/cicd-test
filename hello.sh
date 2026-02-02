#!/usr/bin/env bash
set -euo pipefail

# Usage:
#  ./deploy_to_ec2.sh <host> <user> <target_path> <ssh_key_path>
# Or set env vars: TARGET_HOST, TARGET_USER, TARGET_PATH, SSH_KEY

TARGET_HOST="${1:-${TARGET_HOST:-}}"
TARGET_USER="${2:-${TARGET_USER:-ec2-user}}"
TARGET_PATH="${3:-${TARGET_PATH:-/var/www/html}}"
SSH_KEY="${4:-${SSH_KEY:-~/.ssh/id_rsa}}"

if [ -z "$TARGET_HOST" ]; then
  echo "Usage: $0 <host> <user> <target_path> <ssh_key_path>"
  echo "Or set TARGET_HOST, TARGET_USER, TARGET_PATH, SSH_KEY environment variables."
  exit 2
fi

echo "Deploying site to $TARGET_USER@$TARGET_HOST:$TARGET_PATH"

# files to copy
FILES=(index.html styles.css)

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

for f in "${FILES[@]}"; do
  cp "$f" "$TMPDIR/"
done

# copy files using scp
scp -i "$SSH_KEY" -o StrictHostKeyChecking=no -r "$TMPDIR/"* "$TARGET_USER@$TARGET_HOST:/tmp/website_deploy/"

# move files into place on remote, set owner and restart httpd
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$TARGET_USER@$TARGET_HOST" bash -s <<'EOF'
set -euo pipefail
TARGET_PATH="'"$TARGET_PATH"'"
sudo mkdir -p "$TARGET_PATH"
sudo mv /tmp/website_deploy/* "$TARGET_PATH/"
# set ownership - try common apache user names
if id apache >/dev/null 2>&1; then
  SVC_USER=apache
elif id www-data >/dev/null 2>&1; then
  SVC_USER=www-data
else
  SVC_USER=apache || true
fi
sudo chown -R "${SVC_USER}:" "$TARGET_PATH" || true
# restart httpd (systemd) if available
if command -v systemctl >/dev/null 2>&1; then
  sudo systemctl restart httpd || sudo systemctl restart apache2 || true
else
  sudo service httpd restart || sudo service apache2 restart || true
fi
EOF

echo "Deployment complete. Visit http://$TARGET_HOST/ to verify."
