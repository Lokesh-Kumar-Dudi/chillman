#!/bin/bash

# --- 1. Introduction & Explanation ---
clear
echo "================================================================"
echo "                 🧊 Chillman Installer 🧊                       "
echo "================================================================"
echo "How this works:"
echo "1. DAEMON: A lightweight background timer tracks your focus and rest phases."
echo "2. AUTOSTART: It will automatically launch when you log into your computer."
echo "3. ALIAS: It adds 'chillman' to your terminal so you can configure it easily."
echo "4. MESSAGES: You just type the message you want, and the system will automatically"
echo "   handle the text-to-speech (spd-say) and the desktop notification."
echo ""
echo "Defaults: 50 mins focus, 10 mins rest."
echo "================================================================"

# FIX: Explicitly read from the terminal so curl | bash doesn't skip it
read -p "Press [Enter] to continue with setup, or [Ctrl+C] to cancel..." < /dev/tty

# --- 2. Paths & Directories ---
CONFIG_DIR="$HOME/.config/chillman"
CONFIG_FILE="$CONFIG_DIR/config.env"
DAEMON_FILE="$CONFIG_DIR/daemon.sh"
CLI_FILE="$CONFIG_DIR/chillman.sh"
AUTOSTART_FILE="$HOME/.config/autostart/chillman.desktop"

echo -e "\n⚙️ Creating directories..."
mkdir -p "$CONFIG_DIR"
mkdir -p "$HOME/.config/autostart"

# --- 3. Create Default Configuration ---
echo "⚙️ Creating default config..."
if [ ! -f "$CONFIG_FILE" ]; then
    cat <<'EOF' > "$CONFIG_FILE"
WORK_MINUTES=50
BREAK_MINUTES=10
GETUP_MESSAGE="Time to stretch. You have been working hard."
SITDOWN_MESSAGE="Break is over. Time to get back to work."
EOF
fi

# --- 4. Create the Background Daemon ---
echo "⚙️ Creating background daemon..."
cat <<'EOF' > "$DAEMON_FILE"
#!/bin/bash
CONFIG_FILE="$HOME/.config/chillman/config.env"
sleep 15 # Wait for desktop to load on boot

while true; do
    source "$CONFIG_FILE"
    
    # Focus phase
    sleep $((WORK_MINUTES * 60))
    spd-say "$GETUP_MESSAGE"
    notify-send -u critical -a "Chillman" "Time to stretch!" "$GETUP_MESSAGE"
    
    # Rest phase
    sleep $((BREAK_MINUTES * 60))
    spd-say "$SITDOWN_MESSAGE"
    notify-send -u critical -a "Chillman" "Break is over!" "$SITDOWN_MESSAGE"
done
EOF
chmod +x "$DAEMON_FILE"

# --- 5. Create the CLI Manager Tool ---
echo "⚙️ Creating the CLI tool..."
cat <<'EOF' > "$CLI_FILE"
#!/bin/bash
CONFIG_DIR="$HOME/.config/chillman"
CONFIG_FILE="$CONFIG_DIR/config.env"
DAEMON_FILE="$CONFIG_DIR/daemon.sh"
AUTOSTART_FILE="$HOME/.config/autostart/chillman.desktop"

update_config() {
    local key=$1
    local value=$2
    # Remove old key, append new key safely wrapping value in quotes
    grep -v "^${key}=" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp"
    echo "${key}=\"${value}\"" >> "${CONFIG_FILE}.tmp"
    mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
}

apply_changes() {
    pkill -f "daemon.sh" || true
    nohup "$DAEMON_FILE" >/dev/null 2>&1 &
    echo "✅ Changes applied! Background daemon restarted."
}

uninstall_chillman() {
    read -p "Are you sure you want to uninstall Chillman completely? (y/N): " confirm < /dev/tty
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo "🗑️ Stopping daemon..."
        pkill -f "daemon.sh" || true
        
        echo "🗑️ Removing files..."
        rm -rf "$CONFIG_DIR"
        rm -f "$AUTOSTART_FILE"
        
        echo "🗑️ Removing alias from ~/.bashrc..."
        sed -i '/# Chillman CLI/d' ~/.bashrc
        sed -i '/alias chillman=/d' ~/.bashrc
        
        echo "✅ Chillman has been successfully uninstalled!"
        echo "Please run 'source ~/.bashrc' or restart your terminal to complete the process."
        exit 0
    else
        echo "Uninstall cancelled."
    fi
}

case "$1" in
    focus-time|ft)
        if [[ -n "$2" ]]; then
            update_config "WORK_MINUTES" "$2"
            echo "✅ Focus time set to $2 minutes."
            echo "Run 'chillman apply' to restart the timer."
        else
            echo "Usage: chillman focus-time <minutes>"
        fi
        ;;
    rest-time|rt)
        if [[ -n "$2" ]]; then
            update_config "BREAK_MINUTES" "$2"
            echo "✅ Rest time set to $2 minutes."
            echo "Run 'chillman apply' to restart the timer."
        else
            echo "Usage: chillman rest-time <minutes>"
        fi
        ;;
    getup-message|gm)
        if [[ -n "$2" ]]; then
            update_config "GETUP_MESSAGE" "$2"
            echo "✅ Get-up message updated."
            echo "Run 'chillman apply' to restart the timer."
        else
            echo "Usage: chillman getup-message '<your message>'"
        fi
        ;;
    sitdown-message|sm)
        if [[ -n "$2" ]]; then
            update_config "SITDOWN_MESSAGE" "$2"
            echo "✅ Sit-down message updated."
            echo "Run 'chillman apply' to restart the timer."
        else
            echo "Usage: chillman sitdown-message '<your message>'"
        fi
        ;;
    apply)
        apply_changes
        ;;
    status)
        echo "--- Current Configuration ---"
        cat "$CONFIG_FILE"
        echo "-----------------------------"
        if pgrep -f "daemon.sh" > /dev/null; then
            echo "🟢 Daemon Status: RUNNING"
        else
            echo "🔴 Daemon Status: STOPPED"
        fi
        ;;
    uninstall)
        uninstall_chillman
        ;;
    help|*)
        echo "================================================="
        echo "               🧊 Chillman CLI 🧊                "
        echo "================================================="
        echo "Commands:"
        echo "  focus-time       (ft) <mins>  - Set minutes for work (e.g., ft 45)"
        echo "  rest-time        (rt) <mins>  - Set minutes for break (e.g., rt 15)"
        echo "  getup-message    (gm) '<msg>' - Set the voice/text alert for breaks"
        echo "  sitdown-message  (sm) '<msg>' - Set the voice/text alert for work"
        echo "  apply                         - Apply changes & restart timer"
        echo "  status                        - View current config and daemon status"
        echo "  uninstall                     - Remove Chillman from your system entirely"
        echo "  help                          - Show this menu"
        echo "================================================="
        ;;
esac
EOF
chmod +x "$CLI_FILE"

# --- 6. Create Autostart Entry ---
echo "⚙️ Setting up login autostart..."
cat <<EOF > "$AUTOSTART_FILE"
[Desktop Entry]
Type=Application
Exec=$DAEMON_FILE
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Chillman Daemon
Comment=Runs the background timer for break reminders
EOF

# --- 7. Set Up Alias in .bashrc ---
echo "⚙️ Setting up alias in ~/.bashrc..."
if ! grep -q "alias chillman=" "$HOME/.bashrc"; then
    echo -e "\n# Chillman CLI\nalias chillman='$CLI_FILE'" >> "$HOME/.bashrc"
fi

# --- 8. Start the Daemon immediately ---
pkill -f "daemon.sh" || true
nohup "$DAEMON_FILE" >/dev/null 2>&1 &

# --- 9. Final Instructions ---
echo "================================================================"
echo "✅ Setup Complete!"
echo "The timer is now running in the background."
echo ""
echo "To activate the alias in this terminal right now, run:"
echo "👉  source ~/.bashrc"
echo ""
echo "Then type 'chillman help' to see your commands."
echo "================================================================"
