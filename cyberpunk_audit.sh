#!/bin/bash

# Cyberpunk style variables
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
PURPLE='\033[1;35m'
YELLOW='\033[1;33m'
NC='\033[0m'
BOLD='\033[1m'
BLINK='\033[5m'

# Create audit directory (only once)
AUDIT_DIR="/mnt/data/audits/personal"
mkdir -p "$AUDIT_DIR"

# Initialize HTML report
REPORT_FILE="${AUDIT_DIR}/system_audit_$(date +%Y%m%d_%H%M%S).html"
{
echo "<!DOCTYPE html>
<html>
<head>
    <title>CYBERPUNK SYSTEM AUDIT</title>
    <style>
        body {
            background-color: #0a0a12;
            color: #00ff99;
            font-family: 'Courier New', monospace;
            margin: 0;
            padding: 20px;
        }
        .header {
            background-color: #1a1a2e;
            padding: 20px;
            border-bottom: 2px solid #4dffb8;
            margin-bottom: 30px;
        }
        h1 {
            color: #4dffb8;
            text-align: center;
            text-shadow: 0 0 5px #00ff99;
        }
        .section {
            background-color: #121220;
            border-left: 3px solid #4dffb8;
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 0 5px 5px 0;
        }
        h2 {
            color: #66ffcc;
            margin-top: 0;
        }
        pre {
            background-color: #000000;
            padding: 10px;
            border-radius: 5px;
            overflow-x: auto;
            border: 1px solid #333344;
        }
        .progress-container {
            width: 100%;
            background-color: #1a1a2e;
            border-radius: 5px;
            margin: 20px 0;
        }
        .progress-bar {
            height: 20px;
            background-color: #4dffb8;
            border-radius: 5px;
            width: 0%;
            transition: width 0.5s;
            text-align: center;
            line-height: 20px;
            color: #0a0a12;
            font-weight: bold;
        }
        .eta {
            color: #66ffcc;
            font-size: 14px;
            margin-bottom: 10px;
        }
        .timestamp {
            color: #8888ff;
            font-size: 12px;
            text-align: right;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 10px 0;
        }
        th, td {
            border: 1px solid #4dffb8;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #1a1a2e;
        }
    </style>
</head>
<body>
    <div class='header'>
        <h1>🛡️ CYBERPUNK SYSTEM AUDIT 🛡️</h1>
        <div class='timestamp'>Generated on $(date)</div>
    </div>"
} > "$REPORT_FILE"

# Function to add section to HTML report
add_section() {
    local title=$1
    local content=$2
    
    {
        echo "<div class='section'>"
        echo "<h2>${title}</h2>"
        echo "<pre>${content}</pre>"
        echo "</div>"
    } >> "$REPORT_FILE"
}

# Function to add table section
add_table_section() {
    local title=$1
    local content=$2
    
    {
        echo "<div class='section'>"
        echo "<h2>${title}</h2>"
        echo "<table>${content}</table>"
        echo "</div>"
    } >> "$REPORT_FILE"
}

# Function to display cyberpunk progress bar
progress_bar() {
    local current=$1
    local total=$2
    local message=$3
    local start_time=$4
    
    local progress=$((current * 100 / total))
    local elapsed=$(( $(date +%s) - start_time ))
    local remaining=$(( (elapsed * (100 - progress)) / (progress + 1) ))
    
    local eta_str=""
    if [ $progress -gt 0 ]; then
        eta_str=$(date -u -d @${remaining} +"%H:%M:%S")
    else
        eta_str="calculating..."
    fi
    
    echo -ne "\r${CYAN}${BOLD}${message}${NC} ["
    for ((i=0; i<50; i++)); do
        if [ $i -lt $((progress / 2)) ]; then
            echo -ne "${GREEN}█${NC}"
        else
            echo -ne "${PURPLE}░${NC}"
        fi
    done
    echo -ne "] ${progress}% ${BLUE}ETA: ${eta_str}${NC}"
}

# Total steps in audit
TOTAL_STEPS=18
STEP=0
START_TIME=$(date +%s)

# 1. Check disk hardware information
((STEP++))
progress_bar $STEP $TOTAL_STEPS "💽 Checking disk hardware..." $START_TIME
DISK_HW_INFO=$(echo -e "=== SMART DATA ===\n$(sudo smartctl --scan | while read line; do sudo smartctl -i $(echo $line | awk '{print $1}'); done)\n\n=== LSBLK ===\n$(lsblk -o NAME,MODEL,SIZE,ROTA,RO,TYPE,MOUNTPOINT)")
add_section "Disk Hardware Information" "$DISK_HW_INFO"
sleep 1

# 2. Check disk usage
((STEP++))
progress_bar $STEP $TOTAL_STEPS "📊 Checking disk usage..." $START_TIME
DISK_INFO=$(df -h)
add_section "Disk Usage" "$DISK_INFO"
sleep 1

# 3. Check partition structure
((STEP++))
progress_bar $STEP $TOTAL_STEPS "🔧 Checking partitions..." $START_TIME
PARTITION_INFO=$(lsblk -f)
add_section "Partition Structure" "$PARTITION_INFO"
sleep 1

# 4. Check CPU information
((STEP++))
progress_bar $STEP $TOTAL_STEPS "⚡ Checking CPU info..." $START_TIME
CPU_INFO=$(lscpu)
add_section "CPU Information" "$CPU_INFO"
sleep 1

# 5. Check RAM information
((STEP++))
progress_bar $STEP $TOTAL_STEPS "🧠 Checking RAM info..." $START_TIME
RAM_INFO=$(sudo dmidecode --type memory | grep -A5 -E "^Memory Device" | grep -v "No Module Installed")
add_section "RAM Information" "$RAM_INFO"
sleep 1

# 6. Check active processes
((STEP++))
progress_bar $STEP $TOTAL_STEPS "🔄 Checking processes..." $START_TIME
PROCESSES=$(ps aux --sort=-%cpu | head -n 20)
add_section "Top Processes" "$PROCESSES"
sleep 1

# 7. Check apt/dpkg processes
((STEP++))
progress_bar $STEP $TOTAL_STEPS "📦 Checking package manager..." $START_TIME
APT_PROCESSES=$(ps aux | grep -E 'apt|dpkg')
add_section "Package Manager Processes" "$APT_PROCESSES"
sleep 1

# 8. Check system load
((STEP++))
progress_bar $STEP $TOTAL_STEPS "📈 Checking system load..." $START_TIME
LOAD_INFO=$(uptime && echo -e "\n\n$(top -b -n 1 | head -n 20)")
add_section "System Load" "$LOAD_INFO"
sleep 1

# 9. Check firewall status
((STEP++))
progress_bar $STEP $TOTAL_STEPS "🔥 Checking firewall..." $START_TIME
UFW_STATUS=$(sudo ufw status verbose)
add_section "Firewall Status" "$UFW_STATUS"
sleep 1

# 10. Check open ports
((STEP++))
progress_bar $STEP $TOTAL_STEPS "🔌 Checking open ports..." $START_TIME
OPEN_PORTS=$(ss -tulnp)
add_section "Open Ports" "$OPEN_PORTS"
sleep 1

# 11. Check active services
((STEP++))
progress_bar $STEP $TOTAL_STEPS "⚙️ Checking services..." $START_TIME
ACTIVE_SERVICES=$(systemctl list-units --type=service --state=running)
add_section "Active Services" "$ACTIVE_SERVICES"
sleep 1

# 12. Check GPU information
((STEP++))
progress_bar $STEP $TOTAL_STEPS "🎮 Checking GPU info..." $START_TIME
GPU_INFO=$(lspci -nnk | grep -A3 VGA && echo -e "\n\n=== NVIDIA ===\n$(nvidia-smi 2>/dev/null || echo "NVIDIA driver not installed")")
add_section "GPU Information" "$GPU_INFO"
sleep 1

# 13. Check swap and resume
((STEP++))
progress_bar $STEP $TOTAL_STEPS "💾 Checking swap..." $START_TIME
SWAP_INFO=$(sudo swapon --show && echo -e "\n\n=== RESUME ===\n$(cat /etc/initramfs-tools/conf.d/resume 2>/dev/null)")
add_section "Swap Configuration" "$SWAP_INFO"
sleep 1

# 14. Check ACPI logs
((STEP++))
progress_bar $STEP $TOTAL_STEPS "⚡ Checking ACPI logs..." $START_TIME
ACPI_LOGS=$(journalctl -k | grep -i acpi | tail -n 20)
add_section "ACPI Logs" "$ACPI_LOGS"
sleep 1

# 15. Check kernel modules
((STEP++))
progress_bar $STEP $TOTAL_STEPS "🛠️ Checking kernel..." $START_TIME
KERNEL_MODULES=$(lsmod | sort | head -n 20)
add_section "Kernel Modules" "$KERNEL_MODULES"
sleep 1

# 16. Check security config
((STEP++))
progress_bar $STEP $TOTAL_STEPS "🔐 Checking security..." $START_TIME
SECURITY_INFO=$(echo -e "=== SSH ===\n$(sudo sshd -T | grep -E 'PermitRootLogin|PasswordAuthentication')\n\n=== SUDOERS ===\n$(sudo grep -v '^#' /etc/sudoers | grep -v '^$')")
add_section "Security Config" "$SECURITY_INFO"
sleep 1

# 17. Check vulnerabilities
((STEP++))
progress_bar $STEP $TOTAL_STEPS "🛡️ Checking vulns..." $START_TIME
VULN_CHECK=$(sudo grep -r RESUME /etc/initramfs-tools/ && echo -e "\n\n=== AUDIT ===\n$(sudo auditctl -l 2>/dev/null | head -n 10)")
add_section "Vulnerability Checks" "$VULN_CHECK"
sleep 1

# 18. Final system check
((STEP++))
progress_bar $STEP $TOTAL_STEPS "🚀 Finalizing..." $START_TIME
FINAL_CHECK=$(echo -e "=== BOOT ===\n$(who -b)\n\n=== FAILED ===\n$(systemctl --failed)\n\n=== UPDATES ===\n$(cat /var/lib/apt/periodic/update-success-stamp 2>/dev/null)")
add_section "Final Checks" "$FINAL_CHECK"
sleep 1

# Complete HTML report
{
echo "<div class='section'>"
echo "<h2>🎉 Audit Complete!</h2>"
echo "<p>Full system audit completed successfully. Report saved to:</p>"
echo "<pre>${REPORT_FILE}</pre>"
echo "<p>Generated by <strong>ROCyberSolutions</strong> - <a href='https://rocybersolutions.com' style='color: #4dffb8;'>https://rocybersolutions.com</a></p>"
echo "</div>"
echo "</body>"
echo "</html>"
} >> "$REPORT_FILE"

# Final message
echo -e "\n\n${GREEN}${BOLD}✅ SYSTEM AUDIT COMPLETE!${NC}"
echo -e "${CYAN}📄 HTML report generated: ${BLINK}file://${REPORT_FILE}${NC}"
echo -e "${PURPLE}🖥️ All diagnostic data saved to: ${AUDIT_DIR}${NC}"
echo -e "\n${YELLOW}🔗 Connect with us:${NC}"
echo -e "${BLUE}https://x.com/ROCyberSolnX"
echo -e "https://github.com/ROCyberSolutions/"
echo -e "https://rocybersolutions.com${NC}"
