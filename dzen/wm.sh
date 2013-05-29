#! /bin/bash

###########################################################
#
# Output dzen formatted text with information about the
# window manager.
#
# Reference:
# http://crunchbang.org/forums/viewtopic.php?id=18854
#
###########################################################

#XXX
# There is a bug in here somewhere. When you first launch dzen2 (e.g.
# when logging in) the window manager stuff doesn't appear for a while.
# I think it waits until you switch workspaces for it to appear.
#
# In addition, sometimes it is possible to get 2 instances of the workspace
# enumeration. To reproduce this try kill dzen2 from command line then 
# starting it up again, then switching workspace (e.g. right).
#XXX

named_pipe="/tmp/${0##*/}.pipe"

# create named_pipe to feed to dzen
[ ! -p "${named_pipe}" ] && mkfifo "${named_pipe}"

# switch to the given desktop if received with an argument
[ ! -z "${1}" ] && wmctrl -s "${1}"


function pager {
  #echo -n " "
  wmctrl -d | \
    awk '{
    if ($2 =="*")
      printf "^bg(#78a4ff)^fg(#202020) "$10" ^bg()^fg() "
    else
        printf " "$10" "
    }'
  return
}


function main {
  pager
  printf "\n"
}


main > "${named_pipe}" &
