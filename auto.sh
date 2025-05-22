#!/bin/bash

GREEN='\e[1;32m'
NC='\e[0m' # No Color

show_menu() {
  clear
  echo -e "${GREEN}"
  echo "========================================"
  echo "|      Created by ${GREEN}SHAIR${NC}${GREEN}                 |"
  echo "========================================"
  echo "|      GENSYN CONTROL PANEL           |"
  echo "========================================"
  echo -e "${NC}"
  
  echo -e "${GREEN}1) Install Requirements${NC}"
  echo -e "${GREEN}2) Start Gensyn${NC}"
  echo -e "${GREEN}3) Cloud Tunnel${NC}"
  echo -e "${GREEN}4) Backup${NC}"
  echo -e "${GREEN}5) Page Loading Fix${NC}"
  echo -e "${GREEN}6) Killed Fix (16GB Swap)${NC}"
  echo -e "${GREEN}7) 15sec Fixed (Timeout)${NC}"
  echo -e "${GREEN}8) Current Batch Fixed${NC}"
  echo -e "${GREEN}9) Exit${NC}"
  echo "========================================"
  echo -n -e "${GREEN}Enter choice [1-9]: ${NC}"
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
  git clone https://github.com/gensyn-ai/rl-swarm.git

  # Install Cloudflared
  wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
  sudo dpkg -i cloudflared-linux-amd64.deb
  rm cloudflared-linux-amd64.deb

  echo -e "${GREEN}\n=== REQUIREMENTS INSTALLED ===${NC}"
}

start_gensyn() {
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

page_loading_fix() {
  echo -e "\n${GREEN}=== APPLYING PAGE LOADING FIX ===${NC}"
  cd rl-swarm
  curl -o modal-login/app/page.tsx https://raw.githubusercontent.com/shairkhan2/gensyn/main/page.tsx
  cd ..
}

killed_fix() {
  echo -e "\n${GREEN}=== CREATING 16GB SWAP ===${NC}"
  sudo fallocate -l 16G /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  free -h
}

fix_15sec() {
  echo -e "\n${GREEN}=== APPLYING 15SEC FIX ===${NC}"
  cd $HOME/rl-swarm
  sed -i -E 's/(startup_timeout: *float *= *)[0-9.]+/\1120/' $(python3 -c "import hivemind.p2p.p2p_daemon as m; print(m.__file__)")
  cd
}

current_batch_fix() {
  echo -e "\n${GREEN}=== APPLYING BATCH FIX ===${NC}"
  cd $HOME/rl-swarm/hivemind_exp/configs/mac/
  sed -i \
    -e 's/torch_dtype: .*/torch_dtype: float32/' \
    -e 's/bf16: .*/bf16: false/' \
    -e 's/tf32: .*/tf32: false/' \
    -e 's/gradient_checkpointing: .*/gradient_checkpointing: false/' \
    -e 's/per_device_train_batch_size: .*/per_device_train_batch_size: 2/' \
    grpo-qwen-2.5-0.5b-deepseek-r1.yaml
  cd
}

while true; do
  show_menu
  read -r choice
  case $choice in
    1) install_requirements ;;
    2) start_gensyn ;;
    3) cloud_tunnel ;;
    4) run_backup ;;
    5) page_loading_fix ;;
    6) killed_fix ;;
    7) fix_15sec ;;
    8) current_batch_fix ;;
    9) echo -e "${GREEN}\nExiting... Goodbye!${NC}"; exit 0 ;;
    *) echo -e "${GREEN}\nInvalid option. Please choose between 1-9.${NC}" ;;
  esac
  echo -e "\n${GREEN}Press any key to continue...${NC}"
  read -n1 -s
done
