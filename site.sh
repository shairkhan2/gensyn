#!/bin/bash

# Set default web root
WEB_ROOT="/var/www/html"
PROFILE_HTML="$WEB_ROOT/index.html"

# Install nginx if not installed
if ! command -v nginx &> /dev/null; then
  echo "🚀 Installing nginx..."
  sudo apt update && sudo apt install -y nginx
fi

# Write a basic profile page
sudo tee "$PROFILE_HTML" > /dev/null <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Welcome</title>
  <style>
    body {
      font-family: 'Segoe UI', sans-serif;
      background: linear-gradient(to right, #1e3c72, #2a5298);
      color: white;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      height: 100vh;
      margin: 0;
    }
    .container {
      text-align: center;
      background: rgba(0, 0, 0, 0.2);
      padding: 30px 40px;
      border-radius: 10px;
      box-shadow: 0 4px 30px rgba(0,0,0,0.1);
    }
    .hostname {
      margin-top: 10px;
      background-color: #ffffff22;
      padding: 8px 16px;
      border-radius: 20px;
      display: inline-block;
      font-weight: bold;
      font-size: 14px;
    }
    h1 {
      font-size: 2.5rem;
      margin-bottom: 10px;
    }
    p {
      font-size: 1.2rem;
    }
  </style>
</head>
<body>
  <div class="container">
    <h1>🚀 Welcome to your Server</h1>
    <p>This is your public profile page.</p>
    <div class="hostname">Hostname: $(hostname)</div>
  </div>
</body>
</html>
EOF


# Set correct permissions
sudo chown -R www-data:www-data "$WEB_ROOT"
sudo chmod -R 755 "$WEB_ROOT"

# Start and enable nginx
sudo systemctl enable nginx
sudo systemctl restart nginx

# Get public IP
IP=$(curl -s ifconfig.me)
echo "✅ Profile site is live at: http://$IP"
