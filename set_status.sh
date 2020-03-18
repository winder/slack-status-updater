#!/usr/bin/env bash
#
# Copyright (c) 2020 Will Winder

# Purpose:
# Sets slack status according to what network you're connected to. You must
# have a slack app token in the SLACK_TOKEN environment variable, or pass it
# as the single argument to this script. Create a new token on the slack
# website: https://api.slack.com/legacy/custom-integrations/legacy-tokens

# Configuration:
# Use the network, emoji and message arrays below to configure script behavior.
# Values at a given index are related, so if the network at index 1 matches,
# the emoji and message at index 1 will be applied.
#
# network - network SSID or IP address.
# emoji   - status emoji to apply for the network.
# message - status text to apply for the network.
# script  - if the message is an empty line, generate a message with the script.
network=("1.23.45.67"          "Series of Tubes"     "Business Town"  "Starbucks WiFi")
emoji=(  ":house_with_garden:" ":house_with_garden:" ":office:"       ":coffee:")
message=("Working at home"     "Working at home"     "At the office"  "Bucks.")
script="date"

# --------------------------------------------------------------------------- #
if [ $# -eq 1 ]; then
  SLACK_TOKEN="$1"
fi

# Make sure the SLACK_TOKEN is available
if [ -z "$SLACK_TOKEN" ]; then
  echo "Invalid configuration: missing SLACK_TOKEN."
  exit 64 # EX_USAGE
fi

# Make sure the config is correct, they should all be the same size
len=${#network[@]}
if [ $len -ne ${#emoji[@]} -o $len -ne ${#message[@]} ]; then
  echo "Invalid configuration: network, emoji and message arrays must be the same length."
  exit 64 # EX_USAGE
fi

# Grab ssid / public ip address
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  ssid=$(nmcli -t -f active,ssid dev wifi | egrep '^yes' | cut -d: -f2)
  ip=$(curl -s -S ifconfig.me)
elif [[ "$OSTYPE" == "darwin"* ]]; then
  ssid=$(/System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I | awk -F: '/ SSID/{print $2}')
  ip=$(curl -s -S ifconfig.me)
else
  echo "This OS is not supported: $OSTYPE"
  exit 1
fi

MESSAGE=""

# Loop through networks looking for a match
for (( i=0; i < $len; i++)); do
  if [ "$ssid" == "${network[$i]}" -o "$ip" == "${network[$i]}" ]; then
    MESSAGE=${message[$i]}
    if [ "$MESSAGE" == "" -a "$script" != "" ]; then
      MESSAGE=$(eval $script)
    fi

    curl -s -S -X POST -d "token=$SLACK_TOKEN" --data-urlencode "profile={\"status_text\": \"$MESSAGE\", \"status_emoji\": \"${emoji[$i]}\"}" https://slack.com/api/users.profile.set
    exit
  fi
done

if [ "$script" != "" ]; then
  MESSAGE=$(eval $script)
fi
curl -s -S -X POST -d "token=$SLACK_TOKEN" --data-urlencode "profile={\"status_text\": \"$MESSAGE\", \"status_emoji\": \"\"}" https://slack.com/api/users.profile.set
