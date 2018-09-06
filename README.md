```
$ cd sdk-qemu-x86_64/

$ docker build --squash -t sdk-qemu-x86_64 .
```

Go to the directory containing `ViryaOS` tree.

```
$ docker run --rm -ti -v $(pwd):/home/builder/src -v /tmp:/tmp \
       sdk-qemu-x86_64 /bin/su -l -s /bin/sh builder

e30e9cd62ad3:~$ qemu-system-x86_64 -m 512M -smp 2 \
  -nographic -serial stdio -monitor none \
  --bios /usr/share/sdk-bios/qemu_efi_x86_64.fd  \
  -netdev user,id=hostnet0 -device virtio-net-pci,netdev=hostnet0,bus=pci.0,addr=0x3 \
  -device virtio-balloon-pci,id=balloon0,bus=pci.0,addr=0x6 \
  -drive file=/tmp/img/qemu_x86_64.img,if=none,id=drive-virtio-disk0,format=raw,cache=none \
  -device virtio-blk-pci,bus=pci.0,addr=0x4,drive=drive-virtio-disk0,id=virtio-disk0,bootindex=1 \
  -device virtio-rng-pci
```
