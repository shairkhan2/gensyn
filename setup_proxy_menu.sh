#!/bin/bash
# === Dante + ProxyChains MENU INSTALLER ===

echo "=============================="
echo " 🧙 Master Proxy Setup Script"
echo "=============================="
echo ""
echo "Select mode:"
echo "  1) [SERVER] Install Dante SOCKS5 on this VM"
echo "  2) [CLIENT] Setup ProxyChains only"
echo ""

read -p "👉 Enter 1 or 2: " MODE

if [[ "$MODE" == "1" ]]; then
  echo ""
  echo "=============================="
  echo " 🏰 Installing Dante SOCKS5 server..."
  echo "=============================="
  
  sudo apt update -y
  sudo apt install -y dante-server proxychains curl

  cat <<EOF | sudo tee /etc/danted.conf
logoutput: syslog
internal: eth0 port = 1080
external: eth0

method: username none
user.notprivileged: nobody

client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: connect disconnect error
}

pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    protocol: tcp udp
    log: connect disconnect error
}
EOF

  sudo systemctl enable danted
  sudo systemctl restart danted
  sudo systemctl status danted --no-pager

  echo ""
  echo "=============================="
  echo " 🎯 Optionally configure upstream SOCKS5 for ProxyChains too:"
  read -p "👉 Upstream SOCKS5 IP:PORT (or leave blank to skip): " UPSTREAM

  if [[ -n "$UPSTREAM" ]]; then
    PROXY_IP=$(echo $UPSTREAM | cut -d':' -f1)
    PROXY_PORT=$(echo $UPSTREAM | cut -d':' -f2)

    sudo cp /etc/proxychains.conf /etc/proxychains.conf.backup
    sudo sed -i '/\[ProxyList\]/,$d' /etc/proxychains.conf
    echo "[ProxyList]" | sudo tee -a /etc/proxychains.conf
    echo "socks5  $PROXY_IP $PROXY_PORT" | sudo tee -a /etc/proxychains.conf
    sudo sed -i 's/^#proxy_dns/proxy_dns/' /etc/proxychains.conf
    sudo sed -i 's/^dynamic_chain/#dynamic_chain/' /etc/proxychains.conf
    sudo sed -i 's/^#strict_chain/strict_chain/' /etc/proxychains.conf

    echo "[+] Testing with ProxyChains..."
    proxychains curl https://ifconfig.me
  fi

  echo ""
  echo "🎉 Dante SOCKS5 server is ready on eth0:1080"
  echo "=============================="

elif [[ "$MODE" == "2" ]]; then
  echo ""
  echo "=============================="
  echo " 🛰️  ProxyChains CLIENT setup"
  echo "=============================="

  sudo apt update -y
  sudo apt install -y proxychains curl

  read -p "👉 Enter UPSTREAM SOCKS5 IP:PORT: " UPSTREAM

  PROXY_IP=$(echo $UPSTREAM | cut -d':' -f1)
  PROXY_PORT=$(echo $UPSTREAM | cut -d':' -f2)

  sudo cp /etc/proxychains.conf /etc/proxychains.conf.backup
  sudo sed -i '/\[ProxyList\]/,$d' /etc/proxychains.conf
  echo "[ProxyList]" | sudo tee -a /etc/proxychains.conf
  echo "socks5  $PROXY_IP $PROXY_PORT" | sudo tee -a /etc/proxychains.conf
  sudo sed -i 's/^#proxy_dns/proxy_dns/' /etc/proxychains.conf
  sudo sed -i 's/^dynamic_chain/#dynamic_chain/' /etc/proxychains.conf
  sudo sed -i 's/^#strict_chain/strict_chain/' /etc/proxychains.conf

  echo "[+] Testing with ProxyChains..."
  proxychains curl https://ifconfig.me

  echo ""
  echo "✅ ProxyChains is ready on this VM"
  echo "=============================="

else
  echo "❌ Invalid option! Please run the script again and pick 1 or 2."
  exit 1
fi
