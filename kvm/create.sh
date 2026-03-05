#!/usr/bin/env bash

function install()
{
  network
  userdata

  sudo qemu-img create -b /var/lib/libvirt/images/${image} -f qcow2 -F qcow2 /var/lib/libvirt/images/${name}.qcow2 50G
  sudo virt-install \
    --name ${name} \
    --disk path="/var/lib/libvirt/images/${name}.qcow2",device=disk,bus=scsi \
    --os-variant "${os_variant}" \
    --network network=cka-net,model=virtio \
    --virt-type kvm \
    --vcpus "${vcpu}" \
    --memory "${ram}" \
    --console pty,target_type=serial \
    --cloud-init user-data=./user-data.yml,network-config=./network.yml \
    --import \
    --noautoconsole

  rm -f network.yml
  rm -f user-data.yml
}

function network()
{
  cat > network.yml <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    ${interface}:
      dhcp4: false
      addresses:
        - ${ip}/24
      gateway4: 10.100.100.1
      nameservers:
        addresses: [8.8.8.8, 1.1.1.1]
EOF
}

function userdata()
{
  cat > user-data.yml <<EOF
#cloud-config

disable_root: 0
ssh_pwauth: 1

chpasswd:
  expire: false
  list: |
    root:123456

preserve_hostname: false

fqdn: ${name}
hostname: ${name}

users:
  - name: root
    ssh_authorized_keys:
      - $(cat ~/.ssh/id_ed25519.pub)

write_files:
  - path: /root/.ssh/id_ed25519
    owner: root:root
    permissions: 0o600
    defer: true
    encoding: base64
    content: |
      $(base64 -w0 < ~/.ssh/id_ed25519)

  - path: /root/.ssh/id_ed25519.pub
    owner: root:root
    permissions: 0o644
    defer: true
    encoding: base64
    content: |
      $(base64 -w0 < ~/.ssh/id_ed25519.pub)

  - path: /root/.ssh/config
    owner: root:root
    permissions: 0o644
    defer: true
    encoding: base64
    content: SG9zdCAqCiAgU3RyaWN0SG9zdEtleUNoZWNraW5nIG5vCg==

package_update: true
package_upgrade: true

EOF
}

#==================================
# Install
#==================================
while read temp;
do
  if [[ ! $temp =~ ^# ]]
  then
    export name=$(awk '{print $1}' <<< ${temp})
    export ram=$(awk '{print $2}' <<< ${temp})
    export vcpu=$(awk '{print $3}' <<< ${temp})
    export ip=$(awk '{print $4}' <<< ${temp})
    export image=$(awk '{print $5}' <<< ${temp})

    if [[ ${image} =~ ^rocky ]]
    then
     export os_variant="rocky9" 
     export interface="eth0"
    else
     export os_variant="ubuntu-stable-latest"
     export interface="enp1s0"     
    fi

    echo "Install Vm: ${name}"
    echo
    install
    echo

  fi
done < hosts.txt

rm -f ~/.ssh/known_hosts
