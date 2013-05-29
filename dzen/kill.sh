#! /bin/bash

# kill any process with dzen2 in the name
# use at your own risk
for pid in `ps aux | grep dzen2 | grep -v "grep" | sed 's/\s\+/ /g' | cut -d " " -f 2 | tail -4 | xargs`
do 
  kill -9 $pid;
done
