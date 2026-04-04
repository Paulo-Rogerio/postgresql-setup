#!/usr/bin/env bash

function check(){
    local ip=$1
    todo=true
    while ${todo};
    do
      nc ${ip} 22 -vz 2> /dev/null
      [[ $? -eq 0 ]] && export todo=false
      echo "Waiting Heath Port 22 to ${ip}...."
      sleep 3
    done
    echo "SSH Done"
}

while read temp;
do
  if [[ ! $temp =~ ^# ]]
  then
    ip=$(awk '{print $4}' <<< ${temp})
    check ${ip}
    rsync -avz -e ssh ./data root@${ip}:/root
  fi
done < hosts.txt

