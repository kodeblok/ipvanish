#!/bin/sh
# -----------------------------------------------------------------------------
# The following script can be used on AsusWRT Merlin routers to select a random
# IPVanish VPN server from a list of preferred servers. Script made to run with
# with the basic shell provided on with this router firmware.
#
# Script requires an initial working VPN client configuration in the router
# for IPVanish using VPN client1. Script requires a text file vpnserverlist.txt
# containing the prefixes of the vpn servers you wish to use. ie. sea-a01 or 
# lax-a01. Place server prefixes on their own line in the text file.
#
# Copyright (C) 2018, KodeBloK
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License at
# <http://www.gnu.org/licenses/> for more details.
#
# Requirements: sed, awk and curl
#
# -----------------------------------------------------------------------------
clear
readonly PROGNAME=$(basename $0)
readonly ARGS="$@"
readonly ARGSCOUNT="$#"
readonly SERVER_LIST='/jffs/scripts/vpnserver.list'

get_ip()
{
  local tun_interface="tun11" 
  local ip_address=$(curl -s --interface $tun_interface https://api.ipify.org)
  printf "%s" $ip_address
}

change_vpn()
{
  clear
  printf "\n\n[ -- IPVANISH VPN RANDOMISER -- ]\n\n"
  logger "Running IPVANISH VPN RANDOMISER..."
  local vpn_old=$(nvram get vpn_client1_addr)
  printf "Old VPN config: %s\n" "$vpn_old"
  local ip_old=$(get_ip)
  local server_count=$(wc -l < $SERVER_LIST)
  local random_int=$(awk -v min=1 -v max=$server_count 'BEGIN{srand(); print int(min+rand()*(max-min+1))}')
  local server_selected=$(awk "NR == $random_int" $SERVER_LIST)
  local vpn_new="$server_selected.ipvanish.com"
  printf "New VPN config: %s\n" "$vpn_new"
  printf "\n"
  printf "Setting nvram client vpn values..."
  nvram set vpn_client1_desc=$vpn_new > /dev/null 2>&1
  nvram set vpn_client1_addr=$vpn_new > /dev/null 2>&1  
  printf "DONE\n"
  
  printf "Stopping OPENVPN service..."
  service stop_vpnclient1 > /dev/null 2>&1
  read -t 3
  printf "DONE\n"
  
  printf "Restarting OPENVPN service..."
  service start_vpnclient1 > /dev/null 2>&1
  read -t 10
  printf "DONE\n\n"
  
  logger "Old VPN server was $vpn_old"
  logger "New VPN server set to $vpn_new"
  local ip_new=$(get_ip)
  vpn_message="Old VPN:
$vpn_old
$ip_old

New VPN:
$vpn_new
$ip_new
"
push_over "$vpn_message"
printf "$vpn_message\n"
}

push_over()
{
  message=$1
  printf "Sending Pushover Message..."
  local title="VPN Change"
  local message=$(printf "%s" "$message")

  curl -s \
    --form-string "token=APP_TOKEN_HERE" \
    --form-string "user=USER_TOKEN_HERE" \
    --form-string "title=$title" \
    --form-string "message=$message" \
    https://api.pushover.net/1/messages.json > /dev/null 2>&1
  printf "DONE\n\n" 
}


main()
{
change_vpn
}

main