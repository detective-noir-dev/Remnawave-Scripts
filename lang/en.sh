# shellcheck shell=bash
# English UI dictionary: tr_text KEY. Loaded by scripts.sh.
tr_text() {
    case "$1" in
        # === MAIN MENU - GROUPS ===
        MAIN_TITLE)       echo "🏠 Main Menu" ;;
        GROUP_ID_FLAGS)   echo "🆔 Short ID & Country Flags" ;;
        GROUP_MONITOR)    echo "📊 Resource Monitor" ;;
        GROUP_PORTS)      echo "🔐 Network & Ports" ;;
        GROUP_SETTINGS)   echo "⚙️  Maintenance" ;;
        
        # === SUBMENU: Short ID & Flags ===
        SUB_GEN_IDS)      echo "🎲 Generate shorts_id" ;;
        SUB_FLAG)         echo "🏳️  Get country emoji flag" ;;
        
        # === SUBMENU: Resource Monitor ===
        SUB_MEMORY)       echo "💾 Show free memory" ;;
        SUB_HTOP)         echo "📈 Launch htop" ;;
        SUB_SYSINFO)      echo "🖥️  System information" ;;
        
        # === SUBMENU: Network & Ports ===
        SUB_PORTS)        echo "🔒 Port management" ;;
        
        # === SUBMENU: Maintenance ===
        SUB_UPDATE)       echo "🔄 Check for updates" ;;
        SUB_APT_UPDATE)   echo "📦 Update system packages" ;;
        SUB_DELETE)       echo "🗑️  Uninstall rw-scripts" ;;
        SUB_ROLLBACK)     echo "↩️  Roll back last update" ;;
        SUB_VERIFY)       echo "🔍 Verify installed files" ;;
        ROLLBACK_NONE)    echo "No previous version saved yet (it appears after the next update)." ;;
        ROLLBACK_TARGET)  echo "Previous version:" ;;
        ROLLBACK_ASK)     echo "Roll back to the previous version? (y/n)" ;;
        ROLLBACK_BAD)     echo "The saved copy does not match its checksums - rollback cancelled." ;;
        ROLLBACK_FAIL)    echo "Rollback failed." ;;
        ROLLBACK_DONE)    echo "Rolled back to version" ;;
        VERIFY_TITLE)     echo "Integrity check:" ;;
        VERIFY_NO_SUMS)   echo "No saved SHA256SUMS (it is stored on install/update). Try: rw-scripts verify --online" ;;
        VERIFY_OK)        echo "All files match SHA256SUMS" ;;
        VERIFY_BAD)       echo "Some files differ from SHA256SUMS (corrupted or modified). Reinstall with install.sh." ;;
        
        # === NAVIGATION ===
        MENU_BACK)        echo "⬅️  Back" ;;
        MENU_EXIT)        echo "🚪 Exit" ;;
        PROMPT_CHOICE)    echo "Choose an option:" ;;
        PROMPT_GROUP)     echo "Choose a group:" ;;
        
        # === MESSAGES ===
        MSG_EXIT)         echo "Exiting... Bye 👋" ;;
        MSG_BACK)         echo "Returning to main menu..." ;;
        ERR_CHOICE)       echo "Invalid choice, try again 😅" ;;
        IDS_HOW_MANY)     echo "How many IDs to generate?" ;;
        ERR_NUMBER)       echo "Error: enter a valid number!" ;;
        ERR_GT_ZERO)      echo "Error: number must be greater than zero!" ;;
        IDS_DONE)         echo "IDs generated! Here is your list:" ;;
        ERR_IDS)          echo "An error occurred during generation." ;;
        COUNTRY_PROMPT)   echo "Enter country name (English or Russian, part allowed, 0 = exit):" ;;
        NOTHING_FOUND)    echo "Nothing found for query" ;;
        RESULTS)          echo "Search results:" ;;
        PROMPT_NUM)       echo "Choose number (or 0 for new search):" ;;
        ERR_NUM)          echo "Enter a valid number!" ;;
        ERR_NOT_FOUND)    echo "No option with that number found." ;;
        YOU_SELECTED)     echo "You selected:" ;;
        CHECK_CURR)       echo "Current version:" ;;
        CHECK_LATEST)     echo "Latest version:" ;;
        UPDATE_AVAIL)     echo "New version available! Update? (y/n)" ;;
        UPDATE_DONE)      echo "Script updated to version" ;;
        UPDATE_RESTART)   echo "Restarting..." ;;
        UPDATE_FAIL)      echo "Failed to check for updates." ;;
        UPDATE_BAD_HASH)  echo "Checksum mismatch - update cancelled. If a release was just published, retry in a few minutes." ;;
        UPDATE_NO_HASH)   echo "Could not verify SHA256 (missing SHA256SUMS or sha256sum) - update cancelled." ;;
        NO_UPDATES)       echo "You already have the latest version." ;;
        CONFIRM_DEL)      echo "Are you sure you want to uninstall rw-scripts? (y/n)" ;;
        CANCEL_DEL)       echo "Canceled" ;;
        PRESS_ENTER)      echo "Press Enter to continue..." ;;
        APT_UPDATING)     echo "Updating package lists..." ;;
        APT_UPGRADING)    echo "Installing updates..." ;;
        APT_DONE)         echo "All packages updated!" ;;
        APT_NOT_FOUND)    echo "apt not found. This feature is for Debian/Ubuntu only." ;;
        APT_CONFIRM)      echo "Update system packages? This may take a while. (y/n)" ;;
        APT_UPDATE_OK)    echo "Package lists updated!" ;;
        APT_UPDATE_FAIL)  echo "Failed to update package lists." ;;
        APT_UPGRADE_FAIL) echo "Failed to install updates." ;;
        # === SUBMENU: Server Setup ===
        GROUP_SERVER)         echo "🖥️  Server Setup" ;;
        SUB_SSH_PORT)         echo "🔑 Change SSH port" ;;
        SUB_HY2_INSTALL)      echo "⚡ Install Hysteria2" ;;
        SUB_HY2_REMOVE)       echo "🗑️  Remove Hysteria2" ;;
        SUB_HY2_CONFIG)       echo "📝 Edit Hysteria2 config" ;;
        SUB_HY2_MANAGE)       echo "⚙️  Manage Hysteria2 service" ;;
        SUB_HY2_LOGS)         echo "📋 Hysteria2 logs" ;;
        SSH_ENTER_PORT)       echo "Enter new SSH port (1024-65535):" ;;
        SSH_INVALID_PORT)     echo "Error: enter a port from 1024 to 65535!" ;;
        SSH_CONFIRM)          echo "Change SSH port to" ;;
        SSH_CHANGED)          echo "SSH port changed successfully! New port:" ;;
        SSH_RESTART)          echo "Restarting SSH service..." ;;
        SSH_FAIL)             echo "Error changing port!" ;;
        SSH_WARN)             echo "⚠️  WARNING: Do NOT close your current SSH session!" ;;
        SSH_WARN2)            echo "Open a new connection on the new port first and verify it works." ;;
        HY2_INSTALLING)       echo "Installing Hysteria2..." ;;
        HY2_INSTALLED)        echo "Hysteria2 installed successfully!" ;;
        HY2_REMOVING)         echo "Removing Hysteria2..." ;;
        HY2_REMOVED)          echo "Hysteria2 removed successfully!" ;;
        HY2_NOT_FOUND)        echo "Hysteria2 not found on this system." ;;
        HY2_CONFIRM_REMOVE)   echo "Are you sure you want to remove Hysteria2? (y/n)" ;;
        HY2_DOMAIN_PROMPT)    echo "Enter your domain (e.g. example.com):" ;;
        HY2_PORT_PROMPT)      echo "Enter port for Hysteria2 (default 443):" ;;
        HY2_CONFIG_SAVED)     echo "Config saved. Restart the service to apply changes." ;;
        HY2_SVC_MENU)         echo "Hysteria2 service management" ;;
        HY2_SVC_ENABLE)       echo "▶️  Enable autostart and start" ;;
        HY2_SVC_RESTART)      echo "🔄 Restart service" ;;
        HY2_SVC_STATUS)       echo "📊 Service status" ;;
        HY2_SVC_STOP)         echo "⏹️  Stop service" ;;
        SUB_HY2_VERSION)      echo "🔍 Check Hysteria2 version" ;;
        SUB_HY2_UPDATE)       echo "⬆️  Update Hysteria2" ;;
        HY2_VERSION_CURR)     echo "Installed version:" ;;
        HY2_VERSION_LATEST)   echo "Latest version:" ;;
        HY2_UP_TO_DATE)       echo "You already have the latest Hysteria2!" ;;
        HY2_UPDATE_AVAIL)     echo "Update available! Update now? (y/n)" ;;
        HY2_UPDATING)         echo "Updating Hysteria2..." ;;
        HY2_UPDATED)          echo "Hysteria2 updated successfully!" ;;
        HY2_UPDATE_FAIL)      echo "Failed to update Hysteria2." ;;
        SUB_HY2_SUBMENU)      echo "⚡ Hysteria2" ;;
        SUB_HY2_REMNA)        echo "🔧 Configure Hysteria2 for node (Remnanode)" ;;
        HY2_GROUP_MIHOMO)     echo "── For Mihomo core (standalone Hysteria2 server) ──" ;;
        HY2_GROUP_NODE)       echo "── For Remnawave node (Xray inbound) ──" ;;
        HY2R_NO_COMPOSE)      echo "File /opt/remnanode/docker-compose.yml not found. Is Remnanode installed?" ;;
        HY2R_DOMAIN_PROMPT)   echo "Enter your domain (Let's Encrypt certificate must already exist):" ;;
        HY2R_DOMAIN_INVALID)  echo "Invalid domain." ;;
        HY2R_NO_CERT)         echo "Certificate not found:" ;;
        HY2R_PORT_PROMPT)     echo "Enter UDP port for Hysteria2 (default 443):" ;;
        HY2R_NO_VOLUMES)      echo "No 'volumes:' section in docker-compose.yml. Add the mounts manually." ;;
        HY2R_COMPOSE_DONE)    echo "docker-compose.yml updated (backup: docker-compose.yml.bak)." ;;
        HY2R_HOOK_DONE)       echo "Certificate renewal hook created." ;;
        HY2R_RESTART_CONFIRM) echo "Restart Remnanode now (docker compose down && up -d)? (y/N)" ;;
        HY2R_RESTART_FAIL)    echo "Failed to restart Remnanode." ;;
        HY2R_DONE)            echo "Hysteria2 prepared for Remnanode!" ;;
        HY2R_XRAY_HINT)       echo "Use these certificate paths in the Xray inbound (Remnawave panel):" ;;
        HY2R_ALREADY)         echo "Hysteria2 for Remnanode is already configured." ;;
        HY2R_RECONFIGURE)     echo "Reconfigure anyway? (y/N)" ;;
        SUB_ZAPRET)           echo "🛡️  Install zapret" ;;
        ZAPRET_INSTALLING)    echo "Installing zapret..." ;;
        ZAPRET_DONE)          echo "Zapret installed successfully!" ;;
        ZAPRET_FAIL)          echo "Failed to install zapret." ;;
        SUB_WARP)             echo "☁️  Cloudflare WARP" ;;
        SUB_WARP_INSTALL)     echo "📥 Install WARP" ;;
        SUB_WARP_STATUS)      echo "📋 WARP status" ;;
        SUB_WARP_DISCONNECT)  echo "🛑 Disable WARP" ;;
        SUB_WARP_CONNECT)     echo "🟢 Enable WARP" ;;
        SUB_WARP_UNINSTALL)   echo "🗑️  Uninstall WARP" ;;
        WARP_NOT_INSTALLED)   echo "WARP is not installed. Install it first." ;;
        WARP_STATUS_OK)       echo "WARP is connected" ;;
        WARP_STATUS_BAD)      echo "WARP is NOT connected" ;;
        WARP_ALREADY_OFF)     echo "WARP is already disconnected." ;;
        WARP_ALREADY_ON)      echo "WARP is already connected." ;;
        WARP_DISCONNECTED)    echo "WARP disconnected." ;;
        WARP_CONNECTED)       echo "WARP connected." ;;
        WARP_UNINSTALL_CONFIRM) echo "Remove Cloudflare WARP completely? (y/N)" ;;
        WARP_UNINSTALLING)    echo "Removing WARP..." ;;
        WARP_UNINSTALLED)     echo "WARP removed." ;;
        WARP_CANCELLED)       echo "Cancelled." ;;
        WARP_PORT_PROMPT)     echo "Enter WARP proxy port (default 40000):" ;;
        WARP_PORT_INVALID)    echo "Invalid port, must be 1-65535." ;;
        WARP_ROOT_REQUIRED)   echo "Root privileges are required to install WARP." ;;
        WARP_OS_UNSUPPORTED)  echo "Only Ubuntu and Debian are supported." ;;
        WARP_INSTALLING)      echo "Installing Cloudflare WARP..." ;;
        WARP_REPO_FAIL)       echo "Failed to add Cloudflare repository." ;;
        WARP_PKG_FAIL)        echo "Failed to install cloudflare-warp package." ;;
        WARP_CONFIG_FAIL)     echo "Failed to configure WARP (registration/port/mode)." ;;
        WARP_CONNECT_FAIL)    echo "Failed to connect to WARP." ;;
        WARP_DONE)            echo "WARP installed and connected!" ;;
        WARP_PORT_LABEL)      echo "Proxy port" ;;
        WARP_IP_LABEL)        echo "External IP" ;;
        WARP_COUNTRY_LABEL)   echo "Country" ;;
        WARP_CMDS)            echo "Management commands" ;;
        # === SUBMENU: Third-party Scripts ===
        GROUP_THIRDPARTY)     echo "🔧 Third-party Scripts" ;;
        SUB_EGAMES_RW)        echo "🌐 Remnawave (EGames)" ;;
        SUB_RESHALA)          echo "🤖 Reshala (Remnawave)" ;;
        EGAMES_INSTALLING)    echo "Installing Remnawave by EGames..." ;;
        EGAMES_DONE)          echo "Remnawave by EGames installed successfully!" ;;
        EGAMES_FAIL)          echo "Failed to install Remnawave by EGames." ;;
        RESHALA_INSTALLING)   echo "Installing Reshala..." ;;
        RESHALA_DONE)         echo "Reshala installed successfully!" ;;
        RESHALA_FAIL)         echo "Failed to install Reshala." ;;
        BASHRC_RELOAD)        echo "⚠️  Restart your terminal or run: source ~/.bashrc" ;;
        SUB_MULTITEST)        echo "🧪 Multitest" ;;
        MULTITEST_INSTALLING) echo "Installing Multitest..." ;;
        MULTITEST_DONE)       echo "Multitest installed successfully!" ;;
        MULTITEST_FAIL)       echo "Failed to install Multitest." ;;
        # === SYSTEM CLEANER ===
        GROUP_CLEANER)        echo "🧹 System Cleaner" ;;
        CLEAN_ALL)            echo "✨ Full cleanup (everything)" ;;
        CLEAN_APT)            echo "📦 Clean APT cache" ;;
        CLEAN_JOURNAL)        echo "📚 Clean system logs (journald)" ;;
        CLEAN_DOCKER)         echo "🐳 Clean Docker garbage (prune)" ;;
        CLEAN_TMP)            echo "🗑️  Clean /tmp and user cache" ;;
        CLEAN_SNAP)           echo "🧩 Clean old Snap packages" ;;
        CLEAN_DISK_ANALY)     echo "🔍 Disk analyzer" ;;
        CLEAN_NO_DOCKER)      echo "Docker is not installed." ;;
        CLEAN_NO_SNAP)        echo "Snap is not installed." ;;
        # === MEMORY & SWAP ===
        GROUP_MEMORY)         echo "🧠 Memory & Swap Manager" ;;
        MEM_HYBRID)           echo "🌪️  Hybrid mode (ZRAM + Swap) [RECOMMENDED]" ;;
        MEM_ZRAM_ONLY)        echo "🧩 ZRAM only (turbo compression)" ;;
        MEM_SWAP_ONLY)        echo "💽 Disk Swap only" ;;
        MEM_REMOVE_ALL)       echo "🗑️  Disable ZRAM/Swap completely" ;;
        MEM_SHOW_STATUS)      echo "📊 Detailed memory status" ;;
        MEM_INSTRUCTIONS)     echo "📖 Guide (Docker memory limits)" ;;
        MEM_ZRAM_PERCENT)     echo "Enter compression percent (10-100, default 60):" ;;
        MEM_SWAP_SIZE)        echo "Enter size in GB (e.g. 2):" ;;
        # === REALITY SCANNER ===
        GROUP_SCANNER)        echo "🔍 Reality TLS Scanner" ;;
        SCAN_SINGLE)          echo "🔬 Single scan (OSINT)" ;;
        SCAN_MASS)            echo "🕵️  Mass scan from list" ;;
        SCAN_TARGET)          echo "Enter target (IP or domain):" ;;
        SCAN_PORT)            echo "Port(s) comma-separated (Enter = 443):" ;;
        # === MAIN MENU HINTS ===
        HINT_ID_FLAGS)    echo "└ Generate shorts_id, country flags and names" ;;
        HINT_MONITOR)     echo "└ Free memory, htop, system information" ;;
        HINT_PORTS)       echo "└ Open/close ports, UFW / FirewallD / iptables" ;;
        HINT_SETTINGS)    echo "└ Updates, APT, cleaner, memory, Scanner, uninstall" ;;
        HINT_SERVER)      echo "└ SSH port, Zapret, Hysteria2, Cloudflare WARP" ;;
        HINT_THIRDPARTY)  echo "└ EGames Remnawave, Reshala, Multitest" ;;
        HINT_CLEANER)     echo "└ APT, Docker, journald, /tmp, Snap, disk analyzer" ;;
        HINT_MEMORY)      echo "└ ZRAM, Disk Swap, hybrid mode, Docker limits" ;;
        HINT_SCANNER)     echo "└ SNI for VLESS+Reality, OSINT, mass scan" ;;
    esac
}
