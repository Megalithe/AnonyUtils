#!/bin/bash
# Created by Gabriel McGinn
# chmod script 700 to allow the user to execute the script ./script

# Credentials
# Replace stored credentials before giving to team
username=''
password=''

# Commands' full paths for security and consistency
echo_cmd='/bin/echo'
curl_cmd='/usr/bin/curl'
awk_cmd='/usr/bin/awk'
grep_cmd='/usr/bin/grep'

# Color codes for output
ESC_SEQ="\x1b["
NC="\033[0m"
RED="${ESC_SEQ}31;01m"
GREEN="${ESC_SEQ}32;01m"
YELLOW="${ESC_SEQ}33;01m"
PURPLE="${ESC_SEQ}35;01m"
CYAN="${ESC_SEQ}36;01m"

# API endpoints
API1="" # Host 1 for VPN Server
API2="" # Host 2 for VPN Server

# Service list to iterate over
services=(
  "accountManagementService"
  "webApiService"
  "redisService"
  "exportControlService"
  "otrsService"
)

# Helper function to print status with colors
print_status() {
  local service_name="$1"
  local status="$2"
  printf "${PURPLE}%s: ${NC}" "$service_name"
  if [[ "$status" == "Up" || "$status" == "Reachable" ]]; then
    printf "${GREEN}%s${NC}\n" "$status"
  else
    printf "${RED}Error${NC}\n"
  fi
}

# Ping test function
ping_api() {
  local url="$1"
  local name="$2"
  local ping_response

  # Ping: checking if /health/ping returns "Reachable" (assuming API returns this as plain text)
  ping_response=$($curl_cmd -sfm 15 "$url/health/ping" 2>/dev/null)
  print_status "Pinging $name" "${ping_response:-Error}"
}

# Health check function
health_check() {
  local url="$1"
  local name="$2"
  local json_output
  local status
  declare -A service_status=()

# Address password being passed in curl
  json_output=$($curl_cmd -sfm 15 -u "$username:$password" "$url/health/check" 2>/dev/null)
  if [[ -z "$json_output" ]]; then
    $echo_cmd -e "${RED}Failed to retrieve health check from $name${NC}"
    for svc in "${services[@]}"; do
      service_status[$svc]="Error"
    done
  else
    # Extract service statuses
    for svc in "${services[@]}"; do
      # Using grep and awk to extract status (Up/Down), expecting format: "serviceName":"status"
      status=$(printf '%s\n' "$json_output" | grep -o "\"$svc\"[^}]*" | $awk_cmd -F'"' '{print $4}')
      service_status[$svc]="${status:-Error}"
    done
  fi

  $echo_cmd -e "${CYAN}$name Health Check${NC}"
  for svc in "${services[@]}"; do
    print_status "$svc" "${service_status[$svc]}"
  done

  echo
}

# Start checks
$echo_cmd -e "${CYAN}___ Website check${NC}\n" #ommiting website

# Ping APIs
$echo_cmd -e "${CYAN}Ping APIs${NC}"
ping_api "$API1" "" # Replace with VPN Host 1
ping_api "$API2" "" # Replace with VPN Host 2
echo

# Health Checks
health_check "$API1" "" # Replace with VPN Host 1
health_check "$API2" "" # Replace with VPN Host 2
