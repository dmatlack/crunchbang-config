#! /bin/bash

###########################################################
# 
# Generate output for dzen that describes the system
# state (e.g. battery, volume, etc.).
#
###########################################################

DZEN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $DZEN_DIR/style.sh

ICON_PATH="$DZEN_DIR/icons"
ICON_COLOR=${blue}
ICON_DEAD_COLOR=${_black_}

VOLUME_ICON="$ICON_PATH/vol.1.xbm"
WIRELESS_ICON="$ICON_PATH/wireless1.xbm"

CLOCK_FORMAT="%l:%M %p"

SEP="^fg(${_black_})|^fg()"

function icon_c {
  echo "^fg($2)^i($1)^fg()"
}

function icon {
  icon_c "$1" "$ICON_COLOR"
}

function bar_c {
  echo $1 | dzen2-gdbar -l "" -w 33 -min 0 -max 100 -o -nonl -fg $2 -bg ${_black_}
}

function bar {
  bar_c $1 ${blue}
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
    echo "$(bar_c $percentage ${red}) "
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

  if [ -z "$(amixer get Master | grep "\[on\]")" ]; then
    # muted
    echo -n "$(icon_c $VOLUME_ICON $ICON_DEAD_COLOR)"
    volume="0"
  else 
    echo -n "$(icon $VOLUME_ICON)"
  fi

  echo -n "$(bar $volume)"

  #echo "^ca()^ca()^ca()"
}

function wireless {
  quality=$(cat /proc/net/wireless | grep wlan0 | cut -d " " -f 6 | tr -d ".")

  if [ "$quality" ]; then
    echo -n "$(icon $WIRELESS_ICON)"
    essid=$(iwconfig wlan0 | head -1 | cut -d: -f2 | tr -d '\" ')
    ip="$(ifconfig wlan0  | grep "inet addr" | cut -d: -f2 | cut -d" " -f1)"
    if [ -z "$ip" ]; then
      essid_color="${red}"
    else 
      essid_color="${_green_}"
    fi
    echo -n " ^fg(${essid_color})$essid^fg() ^fg(${_black_})$ip^fg()"
  else
    echo -n "$(icon_c $WIRELESS_ICON $ICON_DEAD_COLOR)"
    #quality="0"
  fi

  #echo -n "$(bar $quality)"
}

function clock {
  echo $(date +"$CLOCK_FORMAT")
}

while :; do
  echo -n "$(wireless) $SEP "
  echo -n "$(battery) $SEP "
  echo -n "$(volume) $SEP "
  echo    "$(clock) "
  sleep 0.5
done
