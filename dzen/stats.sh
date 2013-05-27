#! /bin/bash

###########################################################
# 
# Generate output for dzen that describes the system
# state (e.g. battery, volume, etc.).
#
###########################################################

ICON_PATH="/home/david/.config/dzen/icons"
ICON_COLOR="#78a4ff"

VOLUME_ICON="$ICON_PATH/vol.1.xbm"

# clock configuration
CLOCK_FORMAT="%l:%M %p"

function icon {
  echo "^fg($ICON_COLOR)^i($1)^fg()"
}

function bar_c {
  echo $1 | dzen2-gdbar -w 33 -min 0 -max 100 -o -nonl -fg $2 -bg \#303030
}

function bar {
  bar_c $1 \#78a4ff
}

battery() {
  acpi_ouput=$(acpi -b)
	percentage=$(echo "$acpi_ouput" | cut -d "," -f 2 | tr -d " %")
  status=$(echo "$acpi_ouput" | cut -d " " -f 3 | tr -d ", ")

  if [ $status = Charging ]; then
    echo -n "$(icon $ICON_PATH/ac14.xbm)"
  elif [ $status = Unknown ]; then
    echo -n "$(icon $ICON_PATH/error1.xbm)"
  else
    echo -n "$(icon $ICON_PATH/battery.full.xbm)"
  fi

  if [ $percentage -le 20 ]; then
    echo "$(bar_c $percentage \#d75f5f) "
  else 
    echo "$(bar $percentage) "
  fi
}

volume() {
  volume=$(amixer get Master | egrep -o "[0-9]+%" | tr -d "%")

  #The following lines are buttons to change the sound
  #echo -n "^ca(1, amixer -q set Master 5%-)"
  #echo -n "^ca(3, amixer -q set Master 5%+)"
  #echo -n "^ca(2, amixer -q set Master toggle)"
  echo -n "$(icon $VOLUME_ICON)"

  if [ -z "$(amixer get Master | grep "\[on\]")" ]; then
    volume="0" # muted!
  fi
  echo -n "$(bar $volume)"

  #echo "^ca()^ca()^ca()"
}

function clock {
  echo $(date +"$CLOCK_FORMAT")
}

#ac14 = lightning
#ac15 = lightning
#ac = plug 

while :; do
  echo -n "$(battery)  "
  echo -n "$(volume)  "
  echo    "$(clock) "
  sleep 2
done
