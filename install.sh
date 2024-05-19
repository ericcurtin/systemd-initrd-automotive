#!/bin/bash

set -ex

scp -r -P 2222 ./usr/lib/dracut/modules.d/00systemd-automotive root@127.0.0.1:/usr/lib/dracut/modules.d/
scp -r -P 2222 ./usr/lib/systemd/system/sysroot.service root@127.0.0.1:/usr/lib/systemd/system/
ssh -p 2222 root@127.0.0.1 "dracut --no-hostonly --force -v --show-modules --no-early-microcode --reproducible -M -a \"systemd-automotive\" -o nss-softokn"

