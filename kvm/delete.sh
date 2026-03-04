#!/usr/bin/bash

cd $(dirname $0)

while read temp;
do
  if [[ ! $temp =~ ^# ]]
  then
    node=$(awk '{print $1}' <<< ${temp})
    sudo virsh destroy ${node}
    sudo virsh undefine ${node} --remove-all-storage
    echo "--------------"
  fi
done < hosts.txt
