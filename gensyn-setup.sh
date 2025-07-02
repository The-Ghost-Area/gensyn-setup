#!/bin/bash
set -e

# === Color and formatting definitions ===
GREEN=$(tput setaf 2)
NC=$(tput sgr0)
BOLD=$(tput bold)

# === Random color for banner ===
get_random_color() {
    colors=(1 2 3 4 5 6 9 10 11 12 13 14 21 27 33 39 45 51 81 87 123 129 165 201)
    echo $(tput setaf ${colors[$RANDOM % ${#colors[@]}]})
}

# === Print banner (persistent, full banner) ===
print_banner() {
    clear
    echo "$(get_random_color)"
    echo "██████╗ ███████╗██╗   ██╗██╗██╗     "
    echo "██╔══██╗██╔════╝██║   ██║██║██║     "
    echo "██║  ██║█████╗  ██║   ██║██║██║     "
    echo "██║  ██║██╔══╝  ╚██╗ ██╔╝██║██║     "
    echo "██████╔╝███████╗ ╚████╔╝ ██║███████╗"
    echo "╚═════╝ ╚══════╝  ╚═══╝  ╚═╝╚══════╝"
    echo "${NC}"
    echo "${BOLD}🔥 GENSYN AUTO SETUP SCRIPT BY DEVIL 🔥${NC}"
}

# === Main progress bar ===
print_main_progress() {
    local step=$1
    local total_steps=6
    local progress=$(( (step * 100) / total_steps ))
    local filled=$(( progress / 5 ))
    local empty=$(( 20 - filled ))
    local bar=$(printf "%${filled}s" | tr ' ' '#')$(printf "%${empty}s" | tr ' ' '-')
    echo "Overall Progress: [$bar] $progress%"
}

# === Internal step progress moon loader ===
internal_loader() {
    local pid=$1
    local message=$2
    local step=$3
    local moon_phases=("🌑" "🌒" "🌓" "🌔" "🌕" "🌖" "🌗" "🌘")
    local i=0
    while [ -d /proc/$pid ]; do
        print_banner
        print_main_progress $step
        printf "\r%s [%c]" "$message" "-\\|/" | tr -d '\n'
        echo " Progress: ${moon_phases[$i]}"
        i=$(( (i + 1) % ${#moon_phases[@]} ))
        sleep 0.2
        tput cuu1
        tput el
    done
    print_banner
    print_main_progress $step
    printf "\r%s [✔] ${GREEN}Done${NC}\n" "$message"
    echo "Progress: 🌕"
    sleep 1
}

# === Error handling function ===
handle_error() {
    print_banner
    print_main_progress $2
    printf "\r%s [✖] Failed\n" "$3"
    echo "Error: $1"
    echo "Exiting setup. Please fix the issue and retry."
    cd .. 2>/dev/null || true
    exit 1
}

# === Initial banner ===
print_banner
print_main_progress 0
sleep 2

# === Step 1: System Update & Dependencies ===
print_banner
print_main_progress 1
printf "[1/6] Updating system and installing base packages..."
(sudo apt update -qq && sudo apt install -y -qq \
  sudo python3 python3-venv python3-pip \
  curl wget screen git lsof nano unzip iproute2 \
  build-essential gcc g++ > /dev/null 2>&1) & internal_loader $! "[1/6] Updating system and installing base packages..." 1
[ $? -eq 0 ] || handle_error "Failed to update system or install packages" 1 "[1/6] Updating system and installing base packages..."
sleep 1

# === Step 2: CUDA Setup ===
print_banner
print_main_progress 2
printf "[2/6] Downloading and running CUDA setup..."
([ -f cuda.sh ] && rm cuda.sh; \
curl -s -o cuda.sh https://raw.githubusercontent.com/zunxbt/gensyn-testnet/main/cuda.sh && \
chmod +x cuda.sh && \
bash ./cuda.sh > /dev/null 2>&1) & internal_loader $! "[2/6] Downloading and running CUDA setup..." 2
[ $? -eq 0 ] || handle_error "Failed to download or run CUDA setup" 2 "[2/6] Downloading and running CUDA setup..."
sleep 1

# === Step 3: Node.js and Yarn ===
print_banner
print_main_progress 3
printf "[3/6] Setting up Node.js and Yarn..."
(curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - > /dev/null 2>&1 && \
sudo apt update -qq && sudo apt install -y -qq nodejs > /dev/null 2>&1 && \
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - > /dev/null 2>&1 && \
echo "deb https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list > /dev/null && \
sudo apt update -qq && sudo apt install -y -qq yarn > /dev/null 2>&1) & internal_loader $! "[3/6] Setting up Node.js and Yarn..." 3
[ $? -eq 0 ] || handle_error "Failed to install Node.js or Yarn" 3 "[3/6] Setting up Node.js and Yarn..."
sleep 1

# === Step 4: Version Check ===
print_banner
print_main_progress 4
printf "[4/6] Verifying installed versions..."
(node -v > /dev/null 2>&1 && npm -v > /dev/null 2>&1 && yarn -v > /dev/null 2>&1 && python3 --version > /dev/null 2>&1) & internal_loader $! "[4/6] Verifying installed versions..." 4
[ $? -eq 0 ] || handle_error "Failed to verify versions" 4 "[4/6] Verifying installed versions..."
echo "Versions:"
printf "┌──────────┬──────────┐\n"
printf "│ Node.js  │ $(node -v 2>/dev/null || echo "Not installed") │\n"
printf "│ npm      │ $(npm -v 2>/dev/null || echo "Not installed") │\n"
printf "│ Yarn     │ $(yarn -v 2>/dev/null || echo "Not installed") │\n"
printf "│ Python   │ $(python3 --version 2>/dev/null | cut -d' ' -f2 || echo "Not installed") │\n"
printf "└──────────┴──────────┘\n"
sleep 2

# === Step 5: Clone Gensyn Project and Set Version ===
print_banner
print_main_progress 5
printf "[5/6] Cloning Gensyn AI repository and setting version v0.5.1..."
(git clone --quiet https://github.com/gensyn-ai/rl-swarm.git > /dev/null 2>&1 && \
cd rl-swarm && \
git reset --hard --quiet && \
git pull --quiet origin main > /dev/null 2>&1 && \
git checkout --quiet tags/v0.5.1 > /dev/null 2>&1) & internal_loader $! "[5/6] Cloning Gensyn AI repository and setting version v0.5.1..." 5
[ $? -eq 0 ] || handle_error "Failed to clone or checkout repository version v0.5.1" 5 "[5/6] Cloning Gensyn AI repository and setting version v0.5.1..."
sleep 1

# === Step 6: Python Virtual Environment & Frontend Setup ===
print_banner
print_main_progress 6
printf "[6/6] Setting up Python environment and frontend..."
(python3 -m venv .venv > /dev/null 2>&1 || { echo "Failed to create Python virtual environment"; exit 1; } && \
source .venv/bin/activate && \
[ -f requirements.txt ] && pip install -r requirements.txt > /dev/null 2>&1 || echo "No requirements.txt found, skipping Python dependencies" && \
cd modal-login 2>/dev/null || { echo "Directory modal-login not found. Check if repository was cloned correctly or if tag v0.5.1 contains modal-login."; exit 1; } && \
[ -f package.json ] || { echo "No package.json found in modal-login. Cannot run yarn commands."; exit 1; } && \
yarn install --silent > /dev/null 2>&1 || { echo "yarn install failed. Check network or package.json."; exit 1; } && \
yarn upgrade --silent > /dev/null 2>&1 || { echo "yarn upgrade failed. Check yarn setup."; exit 1; } && \
yarn add next@latest > /dev/null 2>&1 || { echo "Failed to add next@latest. Check yarn setup."; exit 1; } && \
yarn add viem@latest > /dev/null 2>&1 || { echo "Failed to add viem@latest. Check yarn setup."; exit 1; }) & internal_loader $! "[6/6] Setting up Python environment and frontend..." 6
[ $? -eq 0 ] || handle_error "Failed to set up Python environment or frontend. Check requirements.txt, modal-login directory, and yarn setup." 6 "[6/6] Setting up Python environment and frontend..."
cd .. 2>/dev/null || true
sleep 1

# === Final Output ===
print_banner
print_main_progress 6
echo
echo "${BOLD}✅ GENSYN SETUP COMPLETE${NC}"
echo "${BOLD}🛡️ Run inside screen with: screen -S gensyn${NC}"
