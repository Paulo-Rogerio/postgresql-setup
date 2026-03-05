#!/usr/bin/bash

cat > network.xml <<EOF
<network>
  <name>cka-net</name>
  <bridge name="cka-bridge" stp="on" delay="0"/>
  <forward mode='nat'>
    <nat/>
  </forward>
  <ip address="10.100.100.1" netmask="255.255.255.0">
    <dhcp>
      <range start="10.100.100.2" end="10.100.100.100"/>
    </dhcp>
  </ip>
</network>
EOF

sudo virsh net-define network.xml
sudo virsh net-start cka-net
sudo virsh net-autostart cka-net
sudo virsh net-info cka-net
rm -f network.xml
