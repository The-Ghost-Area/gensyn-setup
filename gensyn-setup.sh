#!/bin/bash
set -e

# === Color definitions ===
RED='\033[1;31m'
NC='\033[0m' # No Color

# === DEVIL BANNER ===
echo -e "${RED}"
echo "██████╗ ███████╗██╗   ██╗██╗██╗     "
echo "██╔══██╗██╔════╝██║   ██║██║██║     "
echo "██████╔╝█████╗  ██║   ██║██║██║     "
echo "██╔═══╝ ██╔══╝  ██║   ██║██║██║     "
echo "██║     ███████╗╚██████╔╝██║███████╗"
echo "╚═╝     ╚══════╝ ╚═════╝ ╚═╝╚══════╝"
echo -e "${NC}"
echo "🔥 GENSYN AUTO SETUP SCRIPT BY DEVIL 🔥"
echo

# === Update & install dependencies ===
echo "[1/6] Updating system and installing base packages..."
sudo apt update && sudo apt install -y \
  sudo python3 python3-venv python3-pip \
  curl wget screen git lsof nano unzip iproute2 \
  build-essential gcc g++

# === CUDA Setup ===
echo "[2/6] Downloading and running CUDA setup script..."
[ -f cuda.sh ] && rm cuda.sh
curl -o cuda.sh https://raw.githubusercontent.com/zunxbt/gensyn-testnet/main/cuda.sh
chmod +x cuda.sh
source ./cuda.sh

# === Node.js & Yarn Setup ===
echo "[3/6] Setting up Node.js and Yarn..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt update && sudo apt install -y nodejs

curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install -y yarn

# === Versions Check ===
echo "[4/6] Verifying installed versions..."
echo -n "Node.js: "; node -v
echo -n "npm:     "; npm -v
echo -n "Yarn:    "; yarn -v
echo -n "Python:  "; python3 --version
echo

# === Clone Gensyn Project ===
echo "[5/6] Cloning Gensyn AI repository..."
git clone https://github.com/gensyn-ai/rl-swarm.git
cd rl-swarm
git reset --hard
git pull origin main
git checkout tags/v0.5.1

# === Python Virtual Environment ===
echo "[6/6] Setting up Python virtual environment..."
python3 -m venv .venv
source .venv/bin/activate

# === Frontend Setup ===
echo "[✓] Installing frontend dependencies..."
cd modal-login
yarn install
yarn upgrade
yarn add next@latest
yarn add viem@latest
cd ..

# === DONE ===
echo
echo -e "${RED}✅ GENSYN SETUP COMPLETE${NC}"
echo "You can now start a screen session with: screen -S gensyn"
