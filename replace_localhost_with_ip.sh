#!/bin/bash

# Detect OS
OS="$(uname -s)"

# Function to get local IP depending on OS
get_ip_address() {
    if [[ "$OS" == "Linux" || "$OS" == "Darwin" ]]; then
        # Linux or macOS
        EXTERNAL_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
        if [[ -z "$EXTERNAL_IP" ]]; then
            EXTERNAL_IP=$(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d '/' -f 1 | head -n 1)
        fi
    elif [[ "$OS" == *"MINGW"* || "$OS" == *"CYGWIN"* ]]; then
        # Windows (Git Bash or Cygwin)
        EXTERNAL_IP=$(ipconfig | grep "IPv4 Address" | grep -v "Tunnel" | awk -F': ' '{print $2}' | tr -d ' ' | head -n 1)
    else
        echo "[ERROR] Unsupported OS: $OS"
        exit 1
    fi

    if [[ -z "$EXTERNAL_IP" ]]; then
        echo "[ERROR] Could not retrieve IP address!"
        exit 1
    fi

    echo "$EXTERNAL_IP"
}

# Start
echo "[INFO] Getting internal IP..."
EXTERNAL_IP=$(get_ip_address)
echo "[INFO] Using internal IP: $EXTERNAL_IP"

ROOT_DIR=$(pwd)
LOG_FILE="$ROOT_DIR/replacement.log"
> "$LOG_FILE"

echo "[INFO] Scanning folder: $ROOT_DIR"
echo "[INFO] Logging to: $LOG_FILE"

# Define patterns to replace
declare -a PATTERNS=("http://localhost" "https://localhost" "http://127.0.0.1" "https://127.0.0.1")

# Loop over files
find "$ROOT_DIR" -type f ! -name "$(basename "$0")" | while read -r file; do
    # Skip binary files
    if file "$file" | grep -q "text"; then
        UPDATED=false
        for pattern in "${PATTERNS[@]}"; do
            if grep -q "$pattern" "$file"; then
                sed -i "s|$pattern|http://$EXTERNAL_IP|g" "$file"
                UPDATED=true
            fi
        done

        if [[ "$UPDATED" = true ]]; then
            echo "[UPDATED] $file" >> "$LOG_FILE"
        fi
    fi
done

echo "[✅ DONE] See log at: $LOG_FILE"