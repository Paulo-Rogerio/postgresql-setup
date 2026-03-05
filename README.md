# Postgresql Setup


### Download Images

[Cloud Image - Rocky](https://rockylinux.org/pt-BR/download)

```bash
sudo su
cd /var/lib/libvirt/images
qemu-img convert -f qcow2 -O qcow2 Rocky-9-GenericCloud-Base.latest.x86_64.qcow2 rocky-9-cloudimage.img
```

### List OS Suportados

```bash
virt-install --os-variant list
```