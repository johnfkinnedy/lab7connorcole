#!/bin/bash
########################################################################
#	iplookup.sh
#	  Author:	      
#	  Date:		      2025
# 	Last revised:	2026-03-28
#	  Description:	Menu-driven IP lookup script for Milestone 3
########################################################################

#################### ERROR CHECKING ####################################

# have to sudo to access log files
if [[ "$(whoami)" != 'root' ]]
then
  echo -e "\e[31m"
  echo "You are using a non-privileged account!"
  echo "Usage: sudo $0 [path-to-input file]"
  echo -e "\e[0m"
  exit 1
fi

# check for proper usage
if [[ $# -ne 1 ]]
then
  echo -e "\e[31m"
  echo "Incorrect parameters"
  echo "Usage: sudo $0 [path-to-input file]"
  echo -e "\e[0m"
  exit 1
fi

# check that input file exists
if [[ ! -f $1 ]]
then
  echo -e "\e[31m"
  echo "$1 doesn't exist!"
  echo -e "\e[0m"
  exit 1
fi

#################### COLOR DEFINITIONS #################################

RESET="\e[0m"
CYAN="\e[36m"
MAGENTA="\e[35m"
YELLOW="\u001b[38;5;228m"
PURPLE="\u001b[38;5;141m"
RED="\u001b[38;5;196m"
GREEN="\u001b[38;5;43m"
BLUE="\u001b[38;5;26m"
LTPURP="\u001b[38;5;219m"
ORANGE="\u001b[38;5;216m"

HLINE="=================================================="

#################### REGEX & INITIAL PROCESSING ########################

# IP patterns
QUAD="(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])"
IP="\b($QUAD\.){3}$QUAD\b"

# misc variables
i=0
uniqIps=0

printf "Working... "

# scrape IPs from input file, sort, get unique counts,
# trim off anything with <100 hits, sort by # of hits
regs=$(grep -Eo "rhost=$IP" "$1" |
grep -Eo "$IP" |
sort -g |
uniq -c |
awk '$1 >= 100' |
sort -nr)

# count both total attempts and unique IP addresses
i=$(awk '{sum += $1} END {print sum+0}' <<< "$regs")
uniqIps=$(awk 'END {print NR+0}' <<< "$regs")

echo "Done."
echo

######################## HELPER FUNCTIONS ##############################

pause () {
  printf "${PURPLE}Press any key to continue...${RESET}"
  read -n1 -s </dev/tty
  echo
  return 0
}

display_totals () {
  echo -e "${LTPURP}$HLINE${RESET}"
  echo -e "${LTPURP} There were ${YELLOW}$i${LTPURP} total attempts${RESET}"
  echo -e "${LTPURP} from ${YELLOW}$uniqIps${LTPURP} unique addresses${RESET}"
  echo -e "${LTPURP}$HLINE${RESET}"
  return 0
}

# delete a single UFW rule by rule number if it matches the provided IP
# used before replacing individual IP blocks with /24 CIDR blocks
delete_ip_from_ufw () {
  local target_ip="$1"
  local rule_no

  rule_no=$(ufw status numbered | grep -w "$target_ip" | sed -n 's/^\[ *\([0-9]\+\)\].*//p' | head -n1)

  if [[ -n "$rule_no" ]]
  then
    ufw --force delete "$rule_no" >/dev/null 2>&1
    return 0
  fi

  return 1
}

######################## MENU FUNCTIONS ###############################

show_menu () {
  clear
  echo -e "${CYAN}$HLINE${RESET}"
  echo -e "${CYAN}                IP Lookup Menu${RESET}"
  echo -e "${CYAN}$HLINE${RESET}"
  display_totals
  echo
  echo "  1) Display unique offending IP addresses"
  echo "  2) Show detailed IP information"
  echo "  3) Add offenders to UFW"
  echo "  4) Bracket IPs into /24 CIDR blocks & add to UFW"
  echo "  5) Show current UFW firewall rules"
  echo "  6) Reset firewall"
  echo "  7) Quit"
  echo
}

display_unique_ips () {
  clear
  echo -e "${GREEN}Offending IP Addresses${RESET}"
  echo -e "${CYAN}$HLINE${RESET}"

  if [[ -z "$regs" ]]
  then
    echo -e "${RED}No offending IP addresses found.${RESET}"
    echo
    pause
    return 0
  fi

  while read -r count ip
  do
    printf "%-8s %s\n" "$count" "$ip"
  done <<< "$regs"

  echo
  display_totals
  pause
  return 0
}

print_info () {
  clear

  if [[ -z "$regs" ]]
  then
    echo -e "${RED}No offending IP addresses found.${RESET}"
    echo
    pause
    return 0
  fi

  echo -e "${MAGENTA}$HLINE${RESET}"
  echo -e "${MAGENTA}Select an IP Address${RESET}"
  echo -e "${MAGENTA}$HLINE${RESET}"

  # show numbered list
  local index=1
  while read -r count ip
  do
    echo "$index) $ip ($count attempts)"
    ((index++))
  done <<< "$regs"

  echo
  read -p "Enter selection: " selection </dev/tty

  # get selected IP
  local chosen=$(sed -n "${selection}p" <<< "$regs")

  if [[ -z "$chosen" ]]
  then
    echo -e "${RED}Invalid selection.${RESET}"
    pause
    return 0
  fi

  # split values
  local count=$(awk '{print $1}' <<< "$chosen")
  local ip=$(awk '{print $2}' <<< "$chosen")

  clear
  echo -e "${MAGENTA}$HLINE${RESET}"
  echo -e "${MAGENTA}Detailed IP Information${RESET}"
  echo -e "${MAGENTA}$HLINE${RESET}"

  echo -e "${GREEN}IP Address:${RESET} $ip"
  echo -e "${YELLOW}Attempts:${RESET} $count"
  echo

  curl -s "https://ipinfo.io/$ip"
  echo

  pause
  return 0
}

add_ips_to_ufw () {
  clear
  echo -e "${GREEN}Adding offending IPs to UFW...${RESET}"

  if [[ -z "$regs" ]]
  then
    echo -e "${RED}No offending IP addresses found.${RESET}"
    pause
    return 0
  fi

  while read -r count ip
  do
    # Convert this IP to its matching /24 CIDR block.
    local trio=$(awk -F. '{print $1"."$2"."$3}' <<< "$ip")
    local cidr="$trio.0/24"

    # If the whole subnet is already blocked, do not add the single IP.
    if ufw status | grep -qw "$cidr"
    then
      echo -e "${YELLOW}$ip is already covered by $cidr. Skipping.${RESET}"
    elif ufw status | grep -qw "$ip"
    then
      echo -e "${YELLOW}$ip is already in the firewall. Skipping.${RESET}"
    else
      echo "Blocking $ip..."
      ufw insert 1 deny from "$ip" >/dev/null
      echo -e "${GREEN}$ip added to UFW.${RESET}"
    fi
  done <<< "$regs"

  echo
  echo -e "${GREEN}Done adding IPs to firewall.${RESET}"
  pause
  return 0
}
bracket_ips () {
  clear
  echo -e "${GREEN}Converting offending IPs to /24 CIDR blocks and adding them to UFW...${RESET}"

  if [[ -z "$regs" ]]
  then
    echo -e "${RED}No offending IP addresses found.${RESET}"
    pause
    return 0
  fi

  while read -r count ip
  do
    # Strip the last octet and build the /24 CIDR block.
    local trio=$(awk -F. '{print $1"."$2"."$3}' <<< "$ip")
    local cidr="$trio.0/24"

    echo -e "${CYAN}Checking $ip -> $cidr${RESET}"

    # If the individual IP is already blocked, remove it first.
    # This prevents keeping both a single-IP rule and a broader subnet rule.
    if ufw status | grep -qw "$ip"
    then
      if delete_ip_from_ufw "$ip"
      then
        echo -e "${YELLOW}Removed existing single-IP rule for $ip.${RESET}"
      fi
    fi

    # Add the CIDR block only if it is not already present.
    if ufw status | grep -qw "$cidr"
    then
      echo -e "${YELLOW}$cidr is already in UFW. Skipping.${RESET}"
    else
      ufw insert 1 deny from "$cidr" >/dev/null
      echo -e "${GREEN}$cidr added to UFW.${RESET}"
    fi

    echo
  done <<< "$regs"

  echo -e "${GREEN}Done adding CIDR blocks to firewall.${RESET}"
  pause
  return 0
}
show_firewall () {
  clear
  echo -e "${GREEN}Current UFW Firewall Rules:${RESET}"
  echo -e "${CYAN}$HLINE${RESET}"

  ufw status numbered

  echo
  pause
  return 0
}

reset_firewall () {
  clear
  echo -e "${RED}WARNING: This will reset ALL firewall rules.${RESET}"
  read -n1 -p "Do you want to continue (Y/N)? " confirm </dev/tty
  echo

  if [[ "$confirm" != "Y" && "$confirm" != "y" ]]
  then
    echo -e "${YELLOW}Firewall reset cancelled.${RESET}"
    pause
    return 0
  fi

  echo -e "${RED}Resetting UFW firewall...${RESET}"

  ufw --force reset

  # Restore default firewall behavior
  ufw default deny incoming
  ufw default allow outgoing

  # Restore required default rules
  ufw allow 22/tcp
  ufw allow 80/tcp
  ufw allow 443/tcp

  ufw logging on
  ufw enable

  echo
  echo -e "${GREEN}Firewall has been reset and default rules have been restored.${RESET}"
  pause
  return 0
}

######################## MENU / MAIN LOOP ##############################

while true
do
  show_menu
  read -n1 -p "Enter your choice: " choice </dev/tty
  echo

  case "$choice" in
    1) display_unique_ips ;;
    2) print_info ;;
    3) add_ips_to_ufw ;;
    4) bracket_ips ;;
    5) show_firewall ;;
    6) reset_firewall ;;
    7) echo -e "${GREEN}Goodbye!${RESET}"; exit 0 ;;
    *) echo -e "${RED}Invalid option. Please try again.${RESET}"; sleep 1 ;;
  esac
done