#! /bin/bash

FG_COLOR="#999999"
BG_COLOR="#111111"
HEIGHT="20"
Y=0
FONT="-*-terminus-*-r-*-*-*-*-*-*-*-*-*-*"

dzen_cmd="\
dzen2 -fg $FG_COLOR \
      -bg $BG_COLOR \
      -h  $HEIGHT \
      -y  $Y \
      -fn $FONT"

# Display stats on the right
/home/david/.config/dzen/stats.sh | $dzen_cmd -x 500 -w 900 -ta right &

# Dsiplay desktop switcher on the right
tail -f /tmp/wm.sh.pipe | $dzen_cmd -x 0 -w 500 -ta left &
/home/david/.config/dzen/wm.sh 
