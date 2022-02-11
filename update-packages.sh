#!/bin/sh -x
sudo apt update && sudo apt upgrade
flatpak update
pipx upgrade-all
cd ~/Projects/surfraw-elvis/ && { make clean-gen; make -j5 && ./view-diff.sh ; }
