#!/usr/bin/env bash

function check(){
    todo=true
    while ${todo};
    do
      nc 10.100.100.100 22 -vz 2> /dev/null
      [[ $? -eq 0 ]] && export todo=false
      echo "Waiting Heath Port 22...."
      sleep 3
    done
    echo "SSH Done"
}

check
rsync -avz -e ssh ./postgresql root@10.100.100.100:/root
