#!/bin/bash
set -e

# === Color definitions ===
RED='\033[1;31m'
NC='\033[0m' # No Color

# === OG DEVIL BANNER ===
echo -e "${RED}"
echo "██████╗ ███████╗██╗   ██╗██╗██╗     "
echo "██╔══██╗██╔════╝██║   ██║██║██║     "
echo "██║  ██║█████╗  ██║   ██║██║██║     "
echo "██║  ██║██╔══╝  ╚██╗ ██╔╝██║██║     "
echo "██████╔╝███████╗ ╚████╔╝ ██║███████╗"
echo "╚═════╝ ╚══════╝  ╚═══╝  ╚═╝╚══════╝"
echo -e "${NC}"
echo "🔥 GENSYN AUTO SETUP SCRIPT BY DEVIL 🔥"
echo

# === Step 1: System Update & Dependencies ===
echo "[1/6] Updating system and installing base packages..."
sudo apt update && sudo apt install -y \
  sudo python3 python3-venv python3-pip \
  curl wget screen git lsof nano unzip iproute2 \
  build-essential gcc g++

# === Step 2: CUDA Setup ===
echo "[2/6] Downloading and running CUDA setup script..."
[ -f cuda.sh ] && rm cuda.sh
curl -o cuda.sh https://raw.githubusercontent.com/zunxbt/gensyn-testnet/main/cuda.sh
chmod +x cuda.sh
bash ./cuda.sh

# === Step 3: Node.js and Yarn ===
echo "[3/6] Setting up Node.js and Yarn..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt update && sudo apt install -y nodejs

curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install -y yarn

# === Step 4: Version Check ===
echo "[4/6] Verifying installed versions..."
echo -n "Node.js: "; node -v
echo -n "npm:     "; npm -v
echo -n "Yarn:    "; yarn -v
echo -n "Python:  "; python3 --version
echo

# === Step 5: Clone Gensyn Project ===
echo "[5/6] Cloning Gensyn AI repository..."
git clone https://github.com/gensyn-ai/rl-swarm.git
cd rl-swarm
git reset --hard
git pull origin main
git checkout tags/v0.5.1

# === Step 6: Python Virtual Environment & Frontend Setup ===
echo "[6/6] Setting up Python environment and frontend..."
python3 -m venv .venv
source .venv/bin/activate

cd modal-login
yarn install
yarn upgrade
yarn add next@latest
yarn add viem@latest
cd ..

# === DONE ===
echo
echo -e "${RED}✅ GENSYN SETUP COMPLETE${NC}"
echo "🛡️  Run inside screen with: screen -S gensyn"
