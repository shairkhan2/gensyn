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
  echo -e "${GREEN}4) Backup${NC}"
  echo -e "${GREEN}5) Update Repository${NC}"
  echo -e "${GREEN}6) Remote Update & Backup${NC}"
  echo -e "${GREEN}7) Page Loading Fix${NC}"
  echo -e "${GREEN}8) Killed Fix (16GB Swap)${NC}"
  echo -e "${GREEN}9) 15sec Fixed (Timeout)${NC}"
  echo -e "${GREEN}10) Current Batch Fixed${NC}"
  echo -e "${GREEN}11) Exit${NC}"
  echo "========================================"
  echo -n -e "${GREEN}Enter choice [1-11]: ${NC}"
}

install_requirements() {
  echo -e "\n${GREEN}=== INSTALLING REQUIREMENTS ===${NC}"

  # Base packages
  sudo apt update && sudo apt install -y \
    python3 python3-venv python3-pip curl wget screen git lsof gnupg

  # Install Node.js 20
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt update && sudo apt install -y nodejs

  # Add Yarn GPG key and repo properly
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | \
    gpg --dearmor | sudo tee /usr/share/keyrings/yarn-archive-keyring.gpg > /dev/null
  echo "deb [signed-by=/usr/share/keyrings/yarn-archive-keyring.gpg] https://dl.yarnpkg.com/debian stable main" | \
    sudo tee /etc/apt/sources.list.d/yarn.list > /dev/null

  # Install Yarn
  sudo apt update && sudo apt install -y yarn

  # Clone repo
  git clone https://github.com/shairkhan2/rl-swarm.git

  # Install Cloudflared
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
  
  # Execute remote script directly from GitHub
  bash <(curl -s https://raw.githubusercontent.com/shairkhan2/gensyn/main/temp-backup.sh)
  
  echo -e "${GREEN}\n✅ Remote update completed!${NC}"
  echo "Your installation is now up-to-date with the latest version"
}

page_loading_fix() {
  echo -e "\n${GREEN}=== APPLYING PAGE LOADING FIX ===${NC}"
  cd rl-swarm
  curl -o modal-login/app/page.tsx https://raw.githubusercontent.com/shairkhan2/gensyn/main/page.tsx
  cd ..
  echo -e "${GREEN}✅ Page loading fix applied!${NC}"
}

killed_fix() {
  echo -e "\n${GREEN}=== CREATING 16GB SWAP SPACE ===${NC}"
  sudo swapoff /swapfile >/dev/null 2>&1
  sudo rm -f /swapfile
  sudo fallocate -l 16G /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile >/dev/null
  sudo swapon /swapfile
  echo -e "\n${GREEN}Current swap status:${NC}"
  free -h
  echo -e "${GREEN}✅ 16GB swap space created!${NC}"
}

fix_15sec() {
  echo -e "\n${GREEN}=== APPLYING 15SEC TIMEOUT FIX ===${NC}"
  cd $HOME/rl-swarm
  target_file=$(python3 -c "import hivemind.p2p.p2p_daemon as m; print(m.__file__)")
  
  if [ -f "$target_file" ]; then
    sed -i -E 's/(startup_timeout: *float *= *)[0-9.]+/\1120/' "$target_file"
    echo -e "${GREEN}✅ Timeout increased to 120 seconds!${NC}"
  else
    echo -e "${GREEN}⚠️ Error: Target file not found!${NC}"
  fi
  cd
}

current_batch_fix() {
  echo -e "\n${GREEN}=== APPLYING CURRENT BATCH FIX ===${NC}"
  config_file="$HOME/rl-swarm/hivemind_exp/configs/mac/grpo-qwen-2.5-0.5b-deepseek-r1.yaml"
  
  if [ -f "$config_file" ]; then
    sed -i \
      -e 's/torch_dtype: .*/torch_dtype: float32/' \
      -e 's/bf16: .*/bf16: false/' \
      -e 's/tf32: .*/tf32: false/' \
      -e 's/gradient_checkpointing: .*/gradient_checkpointing: false/' \
      -e 's/per_device_train_batch_size: .*/per_device_train_batch_size: 2/' \
      "$config_file"
    echo -e "${GREEN}✅ Batch configuration updated!${NC}"
  else
    echo -e "${GREEN}⚠️ Error: Config file not found!${NC}"
  fi
}

while true; do
  show_menu
  read -r choice
  case $choice in
    1) install_requirements ;;
    2) start_gensyn ;;
    3) cloud_tunnel ;;
    4) run_backup ;;
    5) update_repository ;;
    6) remote_update_backup ;;
    7) page_loading_fix ;;
    8) killed_fix ;;
    9) fix_15sec ;;
    10) current_batch_fix ;;
    11) echo -e "${GREEN}\nExiting... Goodbye!${NC}"; exit 0 ;;
    *) echo -e "${GREEN}\nInvalid option. Please choose between 1-11.${NC}" ;;
  esac
  echo -e "\n${GREEN}Press any key to continue...${NC}"
  read -n1 -s
done