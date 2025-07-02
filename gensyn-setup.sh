#!/bin/bash
set -e

# === Color and formatting definitions ===
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
NC=$(tput sgr0) # No Color
BOLD=$(tput bold)

# === Spinner function ===
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='-\|/'
    while [ -d /proc/$pid ]; do
        local temp=${spinstr#?}
        printf " [%c] " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# === Error handling function ===
handle_error() {
    printf "\r${RED}[✖] Failed${NC}\n"
    echo "${RED}Error: $1${NC}"
    echo "Exiting setup. Please fix the issue and retry."
    exit 1
}

# === Print banner ===
echo "${RED}"
echo "██████╗ ███████╗██╗   ██╗██╗██╗     "
echo "██╔══██╗██╔════╝██║   ██║██║██║     "
echo "██║  ██║█████╗  ██║   ██║██║██║     "
echo "██║  ██║██╔══╝  ╚██╗ ██╔╝██║██║     "
echo "██████╔╝███████╗ ╚████╔╝ ██║███████╗"
echo "╚═════╝ ╚══════╝  ╚═══╝  ╚═╝╚══════╝"
echo "${NC}"
echo "${BOLD}🔥 GENSYN AUTO SETUP SCRIPT BY DEVIL 🔥${NC}"
echo

# === Print initial dashboard ===
echo "╔═══════════════════════ GENSYN AUTO SETUP ═══════════════════════╗"
echo "│ Total Steps: 6                                                │"
echo "│ [ ] 1. Updating system and installing base packages...        │"
echo "│ [ ] 2. Downloading and running CUDA setup...                  │"
echo "│ [ ] 3. Setting up Node.js and Yarn...                         │"
echo "│ [ ] 4. Verifying installed versions...                        │"
echo "│ [ ] 5. Cloning Gensyn AI repository...                        │"
echo "│ [ ] 6. Setting up Python environment and frontend...          │"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo

# === Step 1: System Update & Dependencies ===
printf "[1/6] Updating system and installing base packages..."
(sudo apt update -qq && sudo apt install -y -qq \
  sudo python3 python3-venv python3-pip \
  curl wget screen git lsof nano unzip iproute2 \
  build-essential gcc g++ > /dev/null 2>&1) & spinner $!
[ $? -eq 0 ] || handle_error "Failed to update system or install packages"
printf "\r[1/6] Updating system and installing base packages... [✔] ${GREEN}Done${NC}\n"

# === Step 2: CUDA Setup ===
printf "[2/6] Downloading and running CUDA setup..."
([ -f cuda.sh ] && rm cuda.sh; \
curl -s -o cuda.sh https://raw.githubusercontent.com/zunxbt/gensyn-testnet/main/cuda.sh && \
chmod +x cuda.sh && \
bash ./cuda.sh > /dev/null 2>&1) & spinner $!
[ $? -eq 0 ] || handle_error "Failed to download or run CUDA setup"
printf "\r[2/6] Downloading and running CUDA setup... [✔] ${GREEN}Done${NC}\n"

# === Step 3: Node.js and Yarn ===
printf "[3/6] Setting up Node.js and Yarn..."
(curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - > /dev/null 2>&1 && \
sudo apt update -qq && sudo apt install -y -qq nodejs > /dev/null 2>&1 && \
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - > /dev/null 2>&1 && \
echo "deb https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list > /dev/null && \
sudo apt update -qq && sudo apt install -y -qq yarn > /dev/null 2>&1) & spinner $!
[ $? -eq 0 ] || handle_error "Failed to install Node.js or Yarn"
printf "\r[3/6] Setting up Node.js and Yarn... [✔] ${GREEN}Done${NC}\n"

# === Step 4: Version Check ===
printf "[4/6] Verifying installed versions..."
(node -v > /dev/null 2>&1 && npm -v > /dev/null 2>&1 && yarn -v > /dev/null 2>&1 && python3 --version > /dev/null 2>&1) & spinner $!
[ $? -eq 0 ] || handle_error "Failed to verify versions"
printf "\r[4/6] Verifying installed versions... [✔] ${GREEN}Done${NC}\n"
echo "Versions:"
printf "┌──────────┬──────────┐\n"
printf "│ Node.js  │ $(node -v) │\n"
printf "│ npm      │ $(npm -v)  │\n"
printf "│ Yarn     │ $(yarn -v) │\n"
printf "│ Python   │ $(python3 --version | cut -d' ' -f2) │\n"
printf "└──────────┴──────────┘\n"

# === Step 5: Clone Gensyn Project ===
printf "[5/6] Cloning Gensyn AI repository..."
(git clone --quiet https://github.com/gensyn-ai/rl-swarm.git > /dev/null 2>&1 && \
cd rl-swarm && \
git reset --hard --quiet && \
git pull --quiet origin main > /dev/null 2>&1 && \
git checkout --quiet tags/v0.5.1 > /dev/null 2>&1) & spinner $!
[ $? -eq 0 ] || handle_error "Failed to clone or checkout repository"
printf "\r[5/6] Cloning Gensyn AI repository... [✔] ${GREEN}Done${NC}\n"

# === Step 6: Python Virtual Environment & Frontend Setup ===
printf "[6/6] Setting up Python environment and frontend..."
(python3 -m venv .venv > /dev/null 2>&1 && \
source .venv/bin/activate && \
cd modal-login && \
yarn install --silent > /dev/null 2>&1 && \
yarn upgrade --silent > /dev/null 2>&1 && \
yarn add next@latest viem@latest --silent > /dev/null 2>&1) & spinner $!
[ $? -eq 0 ] || handle_error "Failed to set up Python environment or frontend"
printf "\r[6/6] Setting up Python environment and frontend... [✔] ${GREEN}Done${NC}\n"
cd ..

# === Final Dashboard ===
echo
echo "╔═══════════════════════ GENSYN AUTO SETUP ═══════════════════════╗"
echo "│ Total Steps: 6                                                │"
echo "│ [✔] 1. Updating system and installing base packages... Done   │"
echo "│ [✔] 2. Downloading and running CUDA setup... Done             │"
echo "│ [✔] 3. Setting up Node.js and Yarn... Done                    │"
echo "│ [✔] 4. Verifying installed versions... Done                   │"
echo "│ [✔] 5. Cloning Gensyn AI repository... Done                   │"
echo "│ [✔] 6. Setting up Python environment and frontend... Done     │"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo
echo "${RED}${BOLD}✅ GENSYN SETUP COMPLETE${NC}"
echo "${BOLD}🛡️ Run inside screen with: screen -S gensyn${NC}"
