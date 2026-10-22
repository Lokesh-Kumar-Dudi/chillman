# 🧊 Chillman 

Chillman is a lightweight, background focus timer (Pomodoro-style) for Linux. It runs quietly as a daemon, tracking your work and rest phases, and alerts you using text-to-speech and desktop notifications when it's time to stretch or get back to work. 

## ✨ Features
* **Background Daemon:** Runs silently without keeping a terminal window open.
* **Autostart:** Automatically launches when you log into your desktop environment.
* **Voice & Visual Alerts:** Uses `spd-say` for text-to-speech and `notify-send` for critical desktop popups.
* **Easy CLI Manager:** Configure timers and messages quickly via the `chillman` terminal command.
* **Highly Customizable:** Change your focus duration, break duration, and custom voice messages on the fly.

## 📦 Prerequisites
Before installing, ensure your system has the required notification and speech utilities installed (most Linux distributions come with these by default):
* `spd-say` (usually part of `speech-dispatcher`)
* `notify-send` (usually part of `libnotify-bin`)

## 🚀 Installation
1. Save the provided installer script (e.g., `install.sh`).
2. Make it executable:
   ```bash
   chmod +x install.sh
   ```
3. Run the installer:
   ```bash
   ./install.sh
   ```
4. Reload your `.bashrc` to activate the newly created alias:
   ```bash
   source ~/.bashrc
   ```

## 🛠️ Usage
Once installed, you can manage your timer using the `chillman` command in your terminal.

| Command | Alias | Description | Example |
| :--- | :--- | :--- | :--- |
| `focus-time <mins>` | `ft` | Set the work duration in minutes. | `chillman ft 45` |
| `rest-time <mins>` | `rt` | Set the break duration in minutes. | `chillman rt 10` |
| `getup-message '<msg>'` | `gm` | Set the alert message for breaks. | `chillman gm 'Time to walk!'` |
| `sitdown-message '<msg>'`| `sm` | Set the alert message for work. | `chillman sm 'Back to the grind.'` |
| `apply` | | Restart the background daemon to apply changes. | `chillman apply` |
| `status` | | View current configuration and daemon status. | `chillman status` |
| `help` | | Show the help menu. | `chillman help` |

**Note:** After making any changes to your times or messages, you must run `chillman apply` to restart the timer with the new settings.

## 🗑️ Uninstallation
Chillman includes a built-in uninstaller that will cleanly remove all configuration files, background scripts, autostart entries, and aliases. 

To remove Chillman completely, run:
```bash
chillman uninstall
```
