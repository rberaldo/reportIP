#!/bin/bash

# reportIP.sh is a bash script to send the IP address of a computer to a
# specific email address
# 
# Copyright (C) 2014 Rafael Beraldo <rberaldo at cabaladada dot org>
# 
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
# 
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
# 
# You should have received a copy of the GNU General Public License along with
# this program. If not, see http://www.gnu.org/licenses/.

readonly HOSTNAME=$(hostname)
readonly EMAIL_ADDR="$1"
readonly IP_FILE="/tmp/ip.txt"
readonly REMOTE="canihazip.com/s"
getIP () {
  # Get the IP address from ifconfig.me/ip/
  readonly IP=$(curl "$REMOTE" 2> /dev/null)
  # Since either the computer or $REMOTE might be offline when trying to get
  # the IP, it's a good idea to check if $IP is unset.
  if [[ -z "$IP" ]]
  then
    echo "$(pwd)/$(basename $0)" | at now + 30 minutes 2> /dev/null
    echo "Failed to get IP. Maybe "$REMOTE" is offline?"
    echo "Running again in 30 minutes"
    exit 1; 
  fi
}

if [[ -z "$1" ]]
then
  echo "Usage: $(basename $0) <email address>"
  exit 1
fi

# Let's get our up-to-date IP address. I'll echo all steps through the end of
# the script to make debugging easier.
echo "Getting current IP address"
getIP
echo "Your current IP address is $IP"

if [[ ! -f $IP_FILE ]]
then
  # If $IP_FILE doesn't exist, create one and mail me the IP address.
  echo "IP file doesn't exist, creating one"
  echo $IP > $IP_FILE
  echo "Sending new IP address"
  echo -e "A new /tmp/ip.txt file was created @ "$HOSTNAME"\
    \nYour current IP is $IP" | mail -s "IP report" "$EMAIL_ADDR" || { \
    # or (||), if mail fails, exit with error code > 0 and schedule to run
    # again in 30 minutes
    echo "$(pwd)/$(basename $0)" | at now + 30 minutes 2> /dev/null; echo
    "Running again in 30 minutes"; exit 1; }
  exit 0
else
  # If it exists, compare to current.
  echo "Comparing IPs"
  OLD_IP=$(cat $IP_FILE)
  if [[ "$OLD_IP" == "$IP" ]]
  then
    # If the IPs are equal, it hasn't changed since the last time we checked,
    # so there's no need updating the file or emailing anything.
    echo "Your IP address ($IP) hasn't changed"
    exit 0
  else
    echo $IP > $IP_FILE
    # if the IPs aren't equal, the IP address has changed; thus we must update
    # our IP file and email the new IP address.
    echo "Your IP has changed"
    echo "Sending new IP address"
    echo -e "Your IP has been updated @ "$HOSTNAME"\
      \nYour current IP is $IP" | mail -s "IP report" "$EMAIL_ADDR" || { \
      # or (||), if mail fails, exit with error code > 0 and schedule to run
      # again in 30 minutes
      echo "$(pwd)/$(basename $0)" | at now + 30 minutes 2> /dev/null; echo
      "Running again in 30 minutes"; exit 1; }
    exit 0
  fi
fi

