# Purpose
Sets slack status according to what network you're connected to. You must
have a slack app token in the SLACK_TOKEN environment variable, create a new
token here: https://api.slack.com/legacy/custom-integrations/legacy-tokens

# Dependencies
One of these operating systems
- Linux
- Mac

# Configuration
Use the network, emoji and message arrays below to configure script behavior.
Values at a given index are related, so if the network at index 1 matches,
the emoji and message at index 1 will be applied.

- network - network SSID or IP address.
- emoji   - status emoji to apply for the network.
- message - status text to apply for the network.

### Example configuration
```
network=("1.23.45.67"          "Series of Tubes"     "Business Town"  "Starbucks WiFi")
emoji=(  ":house_with_garden:" ":house_with_garden:" ":office:"       ":coffee:")
message=("Working at home"     "Working at home"     "At the office"  "Bucks.")
```

# Running the script
CRON is good.

Your OS probably has a way to run a script when the network changes.

Run using `$SLACK_TOKEN` environment variable.
```
./set_status.sh
```

Pass token into script.
```
./set_status.sh $SLACK_TOKEN
```

Cron job
```
0 * * * * /home/user/slack_status_script/set_status.sh xoxp-111111111111-222222222222-333333333333-44444444444444444444444444444444
```
