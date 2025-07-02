```bash
#!/bin/bash

# Error pe script ruk jaye
set -e

# Colors aur formatting
GREEN=$(tput setaf 2)
NC=$(tput sgr0)
BOLD=$(tput bold)

# Random color for banner
get_random_color() {
    colors=(1 2 3 4 5 6 9 10 11 12 13 14 21 27 33 39 45 51 81 87 123 129 165 201)
    echo $(tput setaf ${colors[$RANDOM % ${#colors[@]}]})
}

# Banner dikhane ka function
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

# Main progress bar
print_main_progress() {
    local step=$1
    local total_steps=6
    local progress=$(( (step * 100) / total_steps ))
    local filled=$(( progress / 5 ))
    local empty=$(( 20 - filled ))
    local bar=$(printf "%${filled}s" | tr ' ' '#)$(printf "%${empty}s" | tr ' ' '-')
    echo "Overall Progress: [$bar] $progress%"
}

# Moon loader for internal steps
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

# Error handling function
handle_error() {
    print_banner
    print_main_progress $2
    printf "\r%s [✖] Failed\n" "$3"
    echo "Error: $1"
    echo "Setup bandh! Issue theek karo aur dobara try karo."
    cd .. 2>/dev/null || true
    exit 1
}

# Log file setup
LOG_FILE="gensyn_setup.log"
echo "Setup shuru hua at $(date)" | tee -a "$LOG_FILE"

# Initial banner
print_banner
print_main_progress 0
sleep 2

# Step 1: System Update aur Dependencies
print_banner
print_main_progress 1
printf "[1/6] System update aur base packages install ho rahe hain..."
(sudo apt update -qq && sudo apt install -y -qq \
  sudo python3 python3-venv python3-pip \
  curl wget screen git lsof nano unzip iproute2 \
  build-essential gcc g++ > /dev/null 2>&1) & internal_loader $! "[1/6] System update aur base packages install ho rahe hain..." 1
[ $? -eq 0 ] || handle_error "System update ya packages install nahi hue" 1 "[1/6] System update aur base packages install ho rahe hain..."
sleep 1

# Step 2: CUDA Setup
print_banner
print_main_progress 2
printf "[2/6] CUDA download aur setup ho raha hai..."
([ -f cuda.sh ] && rm cuda.sh; \
curl -s -o cuda.sh https://raw.githubusercontent.com/zunxbt/gensyn-testnet/main/cuda.sh && \
chmod +x cuda.sh && \
bash ./cuda.sh > /dev/null 2>&1) & internal_loader $! "[2/6] CUDA download aur setup ho raha hai..." 2
[ $? -eq 0 ] || handle_error "CUDA download ya setup fail hua" 2 "[2/6] CUDA download aur setup ho raha hai..."
sleep 1

# Step 3: Node.js aur Yarn
print_banner
print_main_progress 3
printf "[3/6] Node.js aur Yarn setup ho raha hai..."
(curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - > /dev/null 2>&1 && \
sudo apt update -qq && sudo apt install -y -qq nodejs > /dev/null 2>&1 && \
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - > /dev/null 2>&1 && \
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list > /dev/null && \
sudo apt update -qq && sudo apt install -y -qq yarn > /dev/null 2>&1) & internal_loader $! "[3/6] Node.js aur Yarn setup ho raha hai..." 3
[ $? -eq 0 ] || handle_error "Node.js ya Yarn install nahi hua" 3 "[3/6] Node.js aur Yarn setup ho raha hai..."
sleep 1

# Step 4: Versions check
print_banner
print_main_progress 4
printf "[4/6] Installed versions check ho rahe hain..."
(node -v > /dev/null 2>&1 && npm -v > /dev/null 2>&1 && yarn -v > /dev/null 2>&1 && python3 --version > /dev/null 2>&1) & internal_loader $! "[4/6] Installed versions check ho rahe hain..." 4
[ $? -eq 0 ] || handle_error "Versions check nahi hui" 4 "[4/6] Installed versions check ho rahe hain..."
echo "Versions:"
printf "┌──────────┬──────────┐\n"
printf "│ Node.js  │ $(node -v 2>/dev/null || echo "Not installed") │\n"
printf "│ npm      │ $(npm -v 2>/dev/null || echo "Not installed") │\n"
printf "│ Yarn     │ $(yarn -v 2>/dev/null || echo "Not installed") │\n"
printf "│ Python   │ $(python3 --version 2>/dev/null | cut -d' ' -f2 || echo "Not installed") │\n"
printf "└──────────┴──────────┘\n"
sleep 2

# Step 5: Gensyn Project Clone aur Version Set
print_banner
print_main_progress 5
printf "[5/6] Gensyn AI repository clone aur v0.5.1 set ho raha hai..."
(git clone --quiet https://github.com/gensyn-ai/rl-swarm.git > /dev/null 2>&1 && \
cd rl-swarm && \
git reset --hard --quiet && \
git pull --quiet origin main > /dev/null 2>&1 && \
git checkout --quiet tags/v0.5.1 > /dev/null 2>&1) & internal_loader $! "[5/6] Gensyn AI repository clone aur v0.5.1 set ho raha hai..." 5
[ $? -eq 0 ] || handle_error "Repository clone ya v0.5.1 checkout nahi hua" 5 "[5/6] Gensyn AI repository clone aur v0.5.1 set ho raha hai..."
sleep 1

# Step 6: Python Virtual Env aur Frontend Setup
print_banner
print_main_progress 6
printf "[6/6] Python environment aur frontend setup ho raha hai..."
(python3 -m venv .venv > /dev/null 2>&1 && \
source .venv/bin/activate && \
[ -f requirements.txt ] && pip install -r requirements.txt > /dev/null 2>&1 || echo "No requirements.txt found, skipping Python dependencies" | tee -a "$LOG_FILE" && \
cd modal-login 2>/dev/null || { echo "Directory modal-login not found. Check if repository was cloned correctly." | tee -a "$LOG_FILE"; exit 1; } && \
yarn install --silent > /dev/null 2>&1 && \
yarn upgrade --silent > /dev/null 2>&1 && \
yarn add next@latest viem@latest --silent > /dev/null 2>&1) & internal_loader $! "[6/6] Python environment aur frontend setup ho raha hai..." 6
[ $? -eq 0 ] || handle_error "Python environment ya frontend setup fail hua. requirements.txt, modal-login directory, aur yarn setup check karo." 6 "[6/6] Python environment aur frontend setup ho raha hai..."
cd .. 2>/dev/null || true
sleep 1

# Screen session start
print_banner
print_main_progress 6
printf "Screen session 'gensyn' start ho raha hai..."
screen -dmS gensyn bash -c "cd $(pwd)/rl-swarm && source .venv/bin/activate && exec bash"
[ $? -eq 0 ] || handle_error "Screen session start nahi hui" 6 "Screen session 'gensyn' start ho raha hai..."
printf "Screen session 'gensyn' [✔] ${GREEN}Done${NC}\n"
sleep 1

# Final output
print_banner
print_main_progress 6
echo
echo "${BOLD}✅ GENSYN SETUP PURA HO GAYA!${NC}"
echo "${BOLD}🛡️ Screen session mein jao: screen -r gensyn${NC}"
echo "Log file check karo: $LOG_FILE"
```
