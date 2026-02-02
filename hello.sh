#!/bin/bash
set -e

echo "======================================"
echo "🚀 Installing Grafana"
echo "⏰ Time: $(date)"
echo "======================================"

# Detect OS
if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS=$ID
else
  echo "❌ Cannot detect OS"
  exit 1
fi

echo "🖥 Detected OS: $OS"

# -------------------------------
# AMAZON LINUX
# -------------------------------
if [[ "$OS" == "amzn" ]]; then
  echo "📦 Installing Grafana on Amazon Linux..."

  sudo tee /etc/yum.repos.d/grafana.repo > /dev/null <<EOF
[grafana]
name=Grafana OSS
baseurl=https://packages.grafana.com/oss/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
EOF

  sudo yum install -y grafana

# -------------------------------
# UBUNTU / DEBIAN
# -------------------------------
elif [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
  echo "📦 Installing Grafana on Ubuntu/Debian..."

  sudo apt update -y
  sudo apt install -y apt-transport-https software-properties-common wget

  wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
  sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"

  sudo apt update -y
  sudo apt install -y grafana

else
  echo "❌ Unsupported OS: $OS"
  exit 1
fi

# -------------------------------
# START & ENABLE GRAFANA
# -------------------------------
echo "▶ Starting Grafana service..."
sudo systemctl daemon-reload
sudo systemctl enable grafana-server
sudo systemctl start grafana-server

# -------------------------------
# VERIFY
# -------------------------------
echo "🔍 Checking Grafana status..."
sudo systemctl status grafana-server --no-pager

echo "======================================"
echo "✅ Grafana Installed & Running"
echo "🌐 Access it at: http://<EC2_PUBLIC_IP>:3000"
echo "👤 Default login: admin / admin"
echo "======================================"
