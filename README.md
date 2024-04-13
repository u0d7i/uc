# uConsole stuff

The kit: clockworkPi [uConsole Kit RPI-CM4 Lite](https://www.clockworkpi.com/product-page/uconsole-kit-rpi-cm4-lite)

## Targets
- [x] Recent minimal debian-based OS image
- [ ] Recent kernel package
- [ ] FS encryption (LUKS, preferable root, oportunistic home)

### Recent debian-based OS image
Current low-hanging-fruit approach implies installing old kernel package into new OS image, which may lead to inconsistencies
```
# latest  bullseye 64-bit lite vanila img
wget -c https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2023-05-03/2023-05-03-raspios-bullseye-arm64-lite.img.xz
unxz -k 2023-05-03-raspios-bullseye-arm64-lite.img.xz # don't remove original archive
mv 2023-05-03-raspios-bullseye-arm64-lite.img uc-bullseye-arm64-lite.img
sudo losetup --show -f -P uc-bullseye-arm64-lite.img # assume /dev/loop0 below, parsed outpu in script
sudo mount /dev/loop0p2 /mnt/
sudo mount /dev/loop0p1 /mnt/boot/
sudo mount --bind /dev /mnt/dev/
sudo mount --bind /sys /mnt/sys/
sudo mount --bind /dev/pts /mnt/dev/pts/
sudo chroot /mnt # you are root in chroot after that, no sudo is needed
apt update && apt upgrade -y
touch /boot/cmdline.txt # kernel package install breaks without it
curl -s https://raw.githubusercontent.com/clockworkpi/apt/main/debian/KEY.gpg > /etc/apt/trusted.gpg.d/clockworkpi.asc
echo "deb https://raw.githubusercontent.com/clockworkpi/apt/main/debian/ stable main" > /etc/apt/sources.list.d/clockworkpi.list
apt update
apt install -y uconsole-kernel-cm4-rpi
apt autoremove -y
apt clean
# cleanup
exit
sudo rm -f /mnt/root/.bash_history
sudo umount -R /mnt # recursive
sudo losetup -D /dev/loop0 # assume loop0 above, parse output in script
# burn sd card, assume /dev/sdb (BE SURE)
sudo dd if=uc-bullseye-arm64-lite.img of=/dev/sdb status=progress

```

## Resources:
- [uConsole github repo](https://github.com/clockworkpi/uConsole)
- [uConsole wiki](https://github.com/clockworkpi/uConsole/wiki)
- [clockworkPi community forum](https://forum.clockworkpi.com)
- [uConsole Notes by @selfawaresoup](https://gist.github.com/selfawaresoup/b296f3b82167484a96e4502e74ed3602)

## HW mods and extensions
- [μPico](https://github.com/dotcypress/upico) - RP2040 powered expansion card for GPIO
- [μHub](https://github.com/dotcypress/uhub) - USB Hub Expansion Card
