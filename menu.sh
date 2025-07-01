#!/bin/bash

GREEN='\e[1;32m'
NC='\e[0m' # No Color

show_menu() {
  clear
  echo -e "${GREEN}"
  echo "╔══════════════════════════════════════╗"
  echo "║      🔧  GENSYN SETUP TOOL          ║"
  echo "║      Created by: SHAIR              ║"
  echo "╚══════════════════════════════════════╝"
  echo -e "${NC}"

  echo -e "${GREEN}1) Install Requirements${NC}"
  echo -e "${GREEN}2) Start Gensyn${NC}"
  echo -e "${GREEN}3) Cloud Tunnel${NC}"
  echo -e "${GREEN}4) CLI Sign-Up${NC}"
  echo -e "${GREEN}5) Backup${NC}"
  echo -e "${GREEN}6) Update Repository${NC}"
  echo -e "${GREEN}7) Remote Update & Backup${NC}"
  echo -e "${GREEN}8) VPN Bot Installer${NC}"
  echo -e "${GREEN}9) Live Fake Site${NC}"  # Added new option here
  echo -e "${GREEN}10) Exit${NC}"          # Changed from 9 to 10
  echo "========================================"
  echo -n -e "${GREEN}Enter choice [1-10]: ${NC}"  # Updated range
}

install_requirements() {
  echo -e "\n${GREEN}=== INSTALLING REQUIREMENTS ===${NC}"
  sudo apt update && sudo apt install -y \
    python3 python3-venv python3-pip curl wget screen git lsof gnupg

  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt update && sudo apt install -y nodejs
  sudo apt install tmate -y
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | \
    gpg --dearmor | sudo tee /usr/share/keyrings/yarn-archive-keyring.gpg > /dev/null
  echo "deb [signed-by=/usr/share/keyrings/yarn-archive-keyring.gpg] https://dl.yarnpkg.com/debian stable main" | \
    sudo tee /etc/apt/sources.list.d/yarn.list > /dev/null

  sudo apt update && sudo apt install -y yarn

git clone https://github.com/shairkhan2/rl-swarm.git

  wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
  sudo dpkg -i cloudflared-linux-amd64.deb
  rm cloudflared-linux-amd64.deb

  echo -e "${GREEN}\n=== REQUIREMENTS INSTALLED ===${NC}"
}

start_gensyn() {
  chmod +x rl-swarm/run_rl_swarm.sh
  screen -S Gensyn -X quit 2>/dev/null
  screen -dmS Gensyn bash -c 'cd rl-swarm && python3 -m venv .venv && source .venv/bin/activate && ./run_rl_swarm.sh; exec bash'
  screen -r Gensyn
}

cloud_tunnel() {
  screen -S cloud -X quit 2>/dev/null
  screen -dmS cloud bash -c 'cloudflared tunnel --url http://localhost:3000; exec bash'
  screen -r cloud
}

cli_sign_up() {
  echo -e "\n${GREEN}=== RUNNING CLI SIGN-UP ===${NC}"
  playwright install-deps
  curl -s -o cli-sign-up https://raw.githubusercontent.com/shairkhan2/gensyn/refs/heads/main/cli-sign-up
  python3 cli-sign-up
}

run_backup() {
  echo -e "\n${GREEN}=== RUNNING BACKUP ===${NC}"
  [ -f backup.sh ] && rm backup.sh
  curl -sSL -O https://raw.githubusercontent.com/shairkhan2/gensyn/main/backup.sh
  chmod +x backup.sh
  ./backup.sh
}

update_repository() {
  echo -e "\n${GREEN}=== UPDATING REPOSITORY ===${NC}"
  cd rl-swarm
  git stash push -m "Saving .env changes"
  git pull
  git stash pop
  cd ..
  echo -e "${GREEN}✅ Repository updated to match GitHub state${NC}"
}

remote_update_backup() {
  echo -e "\n${GREEN}=== RUNNING REMOTE UPDATE & BACKUP ===${NC}"
  echo "This will perform a complete refresh:"
  echo "1. Backup your credentials"
  echo "2. Remove old installation"
  echo "3. Fetch latest version directly from GitHub"
  echo "4. Restore your credentials"
  echo -e "\n${GREEN}Starting remote update process...${NC}"
  bash <(curl -s https://raw.githubusercontent.com/shairkhan2/gensyn/main/temp-backup.sh)
  echo -e "${GREEN}\n✅ Remote update completed!${NC}"
}

vpn_bot_installer() {
  echo -e "\n${GREEN}=== INSTALLING VPN BOT ===${NC}"
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/shairkhan2/gensyn-bot/refs/heads/main/installer.sh)"
}

live_fake_site() {
  echo -e "\n${GREEN}=== STARTING LIVE FAKE SITE ===${NC}"
  bash <(curl -fsSL https://raw.githubusercontent.com/shairkhan2/gensyn/refs/heads/main/site.sh)
}

while true; do
  show_menu
  read -r choice
  case $choice in
    1) install_requirements ;;
    2) start_gensyn ;;
    3) cloud_tunnel ;;
    4) cli_sign_up ;;
    5) run_backup ;;
    6) update_repository ;;
    7) remote_update_backup ;;
    8) vpn_bot_installer ;;
    9) live_fake_site ;;  # Added new case for option 9
    10) echo -e "${GREEN}\nExiting... Goodbye!${NC}"; exit 0 ;;  # Changed from 9 to 10
    *) echo -e "${GREEN}\nInvalid option. Please choose between 1-10.${NC}" ;;  # Updated range
  esac
  echo -e "\n${GREEN}Press any key to continue...${NC}"
  read -n1 -s
done
