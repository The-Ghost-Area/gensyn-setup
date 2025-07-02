#!/bin/bash
set -e

# === Color and formatting definitions ===
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
NC=$(tput sgr0)
BOLD=$(tput bold)

# === Print banner (persistent) ===
print_banner() {
    clear
    echo "${RED}"
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

# === Internal step progress loader ===
internal_loader() {
    local pid=$1
    local message=$2
    local loaders=("▁▁▁▁▁▁▁" "▃▁▁▁▁▁▁" "▃▃▁▁▁▁▁" "▃▃▃▁▁▁▁" "▃▃▃▃▁▁▁" "▃▃▃▃▃▁▁" "▃▃▃▃▃▃▁" "▃▃▃▃▃▃▃
