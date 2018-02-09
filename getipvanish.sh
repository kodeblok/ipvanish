#!/bin/sh
# -----------------------------------------------------------------------------
# A shell script to create a list of available IP Vanish VPN servers
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

readonly COMPLETE_LIST="ipvanish_complete.list"
readonly FILTERED_LIST="ipvanish_filtered.list"
readonly TEMP_LIST="ipvanish_temp.list"
readonly PING_LIST="ipvanish_ping.list"
readonly RANK_LIST="ipvanish_rank.list"
readonly IPVANISH_CONFIG_URL="https://www.ipvanish.com/software/configs/"
readonly IPVANISH_CONFIG_HTML="ipvanish_config.html"

version() 
{
echo ""
echo "-- $PROGNAME Version 1.0a --" 
echo ""
}

clear_lists()
{
	printf "Clear existing lists..."
	rm -f $COMPLETE_LIST
	rm -f $FILTERED_LIST
	rm -f $TEMP_LIST
	rm -f $PING_LIST
	rm -f $RANK_LIST
	printf "DONE\n"
}

fetch_data()
{
  	printf "Fetching IP Vanish data..."
	rm -f $IPVANISH_CONFIG_HTML
	curl -s -o $IPVANISH_CONFIG_HTML $IPVANISH_CONFIG_URL
	printf "DONE\n"
}

format_list()
{
	printf "Formatting IP Vanish server list..."
	awk -F'"' '/ipvanish-/{print substr($6, 10, length($6)-14)}' $IPVANISH_CONFIG_HTML \
	| sed 's/.*\(.......\)/\1/' > $COMPLETE_LIST
	printf "DONE\n"
}

filter_list()
{
	printf "Removing unwanted servers from IP Vanish server list..."
	sed '/^mel/d' $COMPLETE_LIST > $FILTERED_LIST
	sed -i '/^syd/d' $FILTERED_LIST
        sed -i '/^gig/d' $FILTERED_LIST
        sed -i '/^jnb/d' $FILTERED_LIST
        sed -i '/^fra/d' $FILTERED_LIST
	sed -i '/^zur/d' $FILTERED_LIST
	sed -i '/^ams/d' $FILTERED_LIST
	sed -i '/^lon/d' $FILTERED_LIST
	sed -i '/^sin/d' $FILTERED_LIST
	sed -i '/^bos/d' $FILTERED_LIST
	sed -i '/^mia/d' $FILTERED_LIST
	sed -i '/^gru/d' $FILTERED_LIST
	sed -i '/^nic/d' $FILTERED_LIST
	sed -i '/^prg/d' $FILTERED_LIST
	sed -i '/^vie/d' $FILTERED_LIST
	sed -i '/^bru/d' $FILTERED_LIST
	sed -i '/^cph/d' $FILTERED_LIST
	sed -i '/^par/d' $FILTERED_LIST
	sed -i '/^hel/d' $FILTERED_LIST
	sed -i '/^bud/d' $FILTERED_LIST
	sed -i '/^lin/d' $FILTERED_LIST
	sed -i '/^zag/d' $FILTERED_LIST
	sed -i '/^vno/d' $FILTERED_LIST
	sed -i '/^gdl/d' $FILTERED_LIST
	sed -i '/^krs/d' $FILTERED_LIST
	sed -i '/^sto/d' $FILTERED_LIST
	sed -i '/^lis/d' $FILTERED_LIST
	sed -i '/^lux/d' $FILTERED_LIST
	sed -i '/^man/d' $FILTERED_LIST
	sed -i '/^sof/d' $FILTERED_LIST
	sed -i '/^mad/d' $FILTERED_LIST
	sed -i '/^osl/d' $FILTERED_LIST
	sed -i '/^otp/d' $FILTERED_LIST
	sed -i '/^dub/d' $FILTERED_LIST
	sed -i '/^iev/d' $FILTERED_LIST
	sed -i '/^tll/d' $FILTERED_LIST
	sed -i '/^rkv/d' $FILTERED_LIST
	sed -i '/^ist/d' $FILTERED_LIST
	sed -i '/^izm/d' $FILTERED_LIST
	sed -i '/^yei/d' $FILTERED_LIST
	sed -i '/^tlv/d' $FILTERED_LIST
	sed -i '/^bts/d' $FILTERED_LIST
	sed -i '/^waw/d' $FILTERED_LIST
	sed -i '/^ath/d' $FILTERED_LIST
	sed -i '/^kiv/d' $FILTERED_LIST
	printf "DONE\n"
}

ping_list()
{
	printf "Performing server list ping speed test...\n"
	local server_count=1
	local server_up=0
	local server_down=0
	local servers_total=$(wc -l < $FILTERED_LIST)

	echo "There are $servers_total IPVanish VPN servers in the list"

	cat $FILTERED_LIST | 
	{
	while read server
	do
	    avg_ping=$(ping -c 1 -q -s 16 -w 1 -W 1 "$server.ipvanish.com" \
	    | tail -1 \
	    | awk '{print $4}' \
	    | cut -d '/' -f 2)
	    if [ $? -eq 0 ] && [ "$avg_ping" != 0 ]; then
	    printf "- Pinging %d of %d \r" $server_count $servers_total
	    #echo "$server.ipvanish.com is up and ping average is $avg_ping"
	    echo "$avg_ping $server" >> $TEMP_LIST
	    server_up=$(($server_up + 1))
	    else
	    #echo "$server.ipvanish.com is not responding"
	    server_down=$(($server_down + 1))
	    fi
	    server_count=$(($server_count + 1))
	done

	printf "\n"
	printf "%s servers responded\n" $server_up
	printf "%d servers did not respond\n" $server_down
	}
	sort -n $TEMP_LIST >> $PING_LIST
}

rank_list()
{
	local rank_count=50
	printf "Generating Top %s server list..." $rank_count
	sed 's/.*\(.......\)/\1/' $PING_LIST \
	| sed -n '1,'$rank_count'p' > $RANK_LIST
	printf "DONE\n"
}

main()
{
  printf "\n[ -- IPVANISH SERVER LIST GENERATOR -- ]\n"
  clear_lists
  fetch_data
  format_list
  filter_list
  ping_list
  rank_list
}

main