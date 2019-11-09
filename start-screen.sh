#!/bin/sh

SCREEN_SESSION_NAME=desktop

# Prevent multiple screens from existing.
if [ $(screen -ls | awk -F'\t' -vscreen=$SCREEN_SESSION_NAME 'match($2, screen "$") {numscreens++} END {print numscreens}') -gt 0 ]; then
	echo existing screen
	exit 1
fi


# Prefixing $TERM with 'screen' is necessary to get drawing for profanity working correctly.
SCREEN_TERM=screen.$TERM
screencmd="screen -S $SCREEN_SESSION_NAME -T $SCREEN_TERM"

# Start programs that I want always on + a shell.
$screencmd -dm bash -c 'exec bash'
$screencmd -t dmesg -X screen dmesg -Hw
$screencmd -t profanity -X screen profanity

exec screen -T $SCREEN_TERM -p bash -r $SCREEN_SESSION_NAME
