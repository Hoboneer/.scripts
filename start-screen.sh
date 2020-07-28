#!/bin/sh

SCREEN_SESSION_NAME=desktop

# Prevent multiple screens from existing.
if [ $(screen -ls | awk -F'\t' -vscreen=$SCREEN_SESSION_NAME -vnumscreens=0 'match($2, screen "$") {numscreens++} END {print numscreens}') -gt 0 ]; then
	echo existing screen
	exit 1
fi


# Prefixing $TERM with 'screen' is necessary to get drawing for profanity working correctly.
# ... but with `st`, there is no `screen.st-256color` in terminfo.  So allow overriding.
# I'll be using `st` from now on anyway, so do this by default.
#SCREEN_TERM="${SCREEN_TERM:-screen.$TERM}"
SCREEN_TERM="${SCREEN_TERM:-$TERM}"
screencmd="screen -S $SCREEN_SESSION_NAME -T $SCREEN_TERM"

# Start programs that I want always on + a shell.
$screencmd -dm bash -c 'exec bash'

# Monitoring programs
$screencmd -X screen -t dmesg sudo dmesg -Hw
$screencmd -X screen htop
# Assumes that this script either: 1. is running under root; or 2. has the capabilities cap_net_{admin,raw} for the kernel, Linux.
$screencmd -X screen /usr/sbin/nethogs

$screencmd -X screen profanity

exec screen -T $SCREEN_TERM -p bash -r $SCREEN_SESSION_NAME
