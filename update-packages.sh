#!/bin/sh -x
sudo apt update && sudo apt upgrade
pipx upgrade-all
cd ~/surfraw-elvis/ && { make clean-gen; make -j5 && ./view-diff.sh ; }
