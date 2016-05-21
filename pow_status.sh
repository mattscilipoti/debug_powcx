#!/bin/sh

# Record pow.cx status and update gist
# Requires:
# - brew install timelimit

GIST_ID=810b5f495ce20e5cf918

# Define your function here
function saveResults {
  # $1 command, $2 args, $3 output file
  echo "Creating $3..."
  echo "" > $3
  appendResults "$1" "$2" $3
}

function appendResults {
  # $1 command, $2 args, $3 output file
  echo "Appending $1 $2 to $3..."
  echo "$ $1 $2" >> $3
  timelimit -T 5 -p "$1" $2 >> $3 2>&1
  # "$1" $2 > $3
  echo "" >> $3
}

function updateGist {
  # $1 command/file label, $2 input file
  gist -u $GIST_ID -f "$ $1" < $2
  echo "Updated GIST: $1"
}

foreach(){
  arr="$(declare -p $1)" ; eval "declare -A f="${arr#*=};
  for i in ${!f[@]}; do $2 "$i" "${f[$i]}"; done
}

echo "Creating Files..."

saveResults "curl" "-s -H host:pow localhost" curl_checks.txt
appendResults "curl" "-s -H host:pow localhost/status.json"  curl_checks.txt
appendResults "curl" "-s http://garnet.dev"  curl_checks.txt

# appendResults "curl" "-s -H host:pow localhost:20559" curl_checks.txt
appendResults "curl" "-s -H host:pow localhost:20559/status.json"  curl_checks.txt
appendResults "curl" "-s http://garnet.dev:20559"  curl_checks.txt


POW_ROOT="$HOME/Library/Application Support/Pow"

saveResults "$POW_ROOT/Current/bin/pow" "--print-config" pow_config.txt
saveResults sudo "pfctl -sa" pfctl.txt
saveResults dns-sd "-G v4 garnet.dev" dns-sd.txt
saveResults scutil --dns scutil.txt
saveResults sysctl net.net.ip.forwarding sysctl.txt
saveResults "tail" "-n40 $HOME/Library/Logs/Pow/access.log" access.log
saveResults "tail" "-n40 $HOME/Library/Logs/Pow/apps/garnet.log" garnet.log

# Couldn't figure out a way to use these commands within saveResults
echo "Creating lsof.txt..."
lsof -i | grep 20559 > lsof.txt
lsof -i | grep 20560 >> lsof.txt
# cat lsof.txt

echo "Creating ipfw.txt..."
sudo ipfw list &> ipfw.txt

echo "Creating ps.txt..."
ps aux | grep '\d pow' > ps.txt


echo "DEBUG"
# cat curl_checks.txt
# cat ps.txt
#

echo "Updating gists..."
updateGist "journal"                   journal.txt
updateGist "curl checks"               curl_checks.txt
updateGist "ps aux | grep pow"         ps.txt
updateGist "pow --print-config"        pow_config.txt
updateGist "sudo pfctl -sa"            pfctl.txt
updateGist "dns-sd -G v4 garnet.dev"   dns-sd.txt
updateGist "scutil --dns > scutil.txt" scutil.txt
updateGist "lsof"                      lsof.txt
updateGist "sudo ipfw list"            ipfw.txt
updateGist "sysctl net.net.ip.forwarding" sysctl.txt
updateGist "pow_status.sh"             pow_status.sh
updateGist "access.log" access.log
updateGist "garnet.log" garnet.log
