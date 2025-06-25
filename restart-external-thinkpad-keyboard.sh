#!/bin/sh
echo "most issues seem to happen after waking from suspend!"
echo "remember to replug the keyboard after suspend!"
# Make sure CapsLock is mapped to Ctrl
setxkbmap -option ctrl:swapcaps_hyper
