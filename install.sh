#!/bin/bash

set -ex

scp -r -P 2222 ./usr/lib/dracut/modules.d/01systemd-initrd-automotive root@127.0.0.1:/usr/lib/dracut/modules.d/
scp -r -P 2222 ./usr/lib/systemd/system/sysroot.service root@127.0.0.1:/usr/lib/systemd/system/
scp -r -P 2222 ../mountgpt/mountgpt.c root@127.0.0.1:~/
ssh -p 2222 root@127.0.0.1 "sed -i \"s/autoinit.rw/ignore_loglevel/g\" /boot/loader/entries/ffffffffffffffffffffffffffffffff-5.14.0-447.400.el9iv.x86_64.conf"
ssh -p 2222 root@127.0.0.1 "gcc -O3 mountgpt.c -l blkid -o /usr/bin/mountgpt"
ssh -p 2222 root@127.0.0.1 "sed -i \"s/autoinit//g\" /usr/lib/dracut/dracut.conf.d/90-image.conf"
ssh -p 2222 root@127.0.0.1 "dracut --no-hostonly --force -v --show-modules --no-early-microcode --reproducible -M -a \"systemd-initrd-automotive\" -o nss-softokn"

