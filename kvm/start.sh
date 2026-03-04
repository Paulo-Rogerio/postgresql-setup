#!/usr/bin/bash

cd $(dirname $0)

while read temp;
do
  if [[ ! ${temp} =~ ^# ]]
  then
    node=$(awk '{print $1}' <<< ${temp})
    sudo virsh start ${node}
    echo "Started ${node}"
    echo "--------------"
  fi
done < hosts.txt
