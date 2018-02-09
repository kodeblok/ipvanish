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
readonly CONFIG_FILE='/etc/openvpn/client1/config.ovpn'
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
  printf "\n[ -- IPVANISH VPN RANDOMISER -- ]\n\n"
  logger "Running IPVANISH VPN RANDOMISER..."
  local vpn_current=$(grep 'ipvanish.com' $CONFIG_FILE)
  local ip_current=$(get_ip)
  printf "Current VPN config: %s\n" "$vpn_current"
  printf "Current VPN IP address: %s\n" "$ip_current"

  local server_count=$(wc -l < $SERVER_LIST)
  local random_int=$(awk -v min=1 -v max=$server_count 'BEGIN{srand(); print int(min+rand()*(max-min+1))}')
  local server_selected=$(awk "NR == $random_int" $SERVER_LIST)
  printf "\n"
  printf "New VPN selected: %s\n" "$server_selected"
  local vpn_new="remote $server_selected.ipvanish.com 443"
  printf "New VPN config: %s\n" "$vpn_new"
  printf "\n"
  printf "Updating config file..."
  sed -i "s/$vpn_current/$vpn_new/g" $CONFIG_FILE
  printf "DONE\n"
  
  printf "Stopping OPENVPN service..."
  service stop_vpnclient1 > /dev/null 2>&1
  read -t 3
  printf "DONE\n"
  
  printf "Restarting OPENVPN service..."
  service start_vpnclient1 > /dev/null 2>&1
  read -t 10
  printf "DONE\n\n"
  
  local ip_new=$(get_ip)
  printf "New VPN IP address: %s\n" $ip_new
  logger "Old VPN server was $vpn_current"
  logger "New VPN server set to $vpn_new"
  printf "\n"
}

main()
{
change_vpn
}

main