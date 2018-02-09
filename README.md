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
