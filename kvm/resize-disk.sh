#!/usr/bin/env bash

function resize()
{
  sudo qemu-img resize /var/lib/libvirt/images/${name}-disk2.qcow2 ${size}
  sudo qemu-img resize /var/lib/libvirt/images/${name}-disk3.qcow2 ${size}
}

read -p "Informe o Novo tamanho do Volume em GB. Ex: ( 4G ) " size

if [[ "${size}" =~ ^[0-9]+G$ ]] 
then
  while read temp;
  do
    if [[ ! $temp =~ ^# ]]
    then
      name=$(awk '{print $1}' <<< ${temp})
      resize
    fi
  done < hosts.txt
else
  echo "valor invalido. Deve-se informa volor em GB. Ex: ( 5G )"
fi

