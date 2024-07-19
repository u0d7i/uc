# uConsole stuff

The kit: clockworkPi [uConsole Kit RPI-CM4 Lite](https://www.clockworkpi.com/product-page/uconsole-kit-rpi-cm4-lite)

## Targets
- [x] Recent minimal debian-based OS image
- [x] Recent kernel package
- [ ] FS encryption (LUKS, preferable root, opportunistic home)

### Recent debian-based OS image
Current low-hanging-fruit approach implies installing old kernel package into new OS image, which may lead to inconsistencies
```
wget -c https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2024-03-15/2024-03-15-raspios-bookworm-arm64-lite.img.xz
unxz -k 2024-03-15-raspios-bookworm-arm64-lite.img.xz # don't remove original archive
mv 2024-03-15-raspios-bookworm-arm64-lite.img uc-bookworm-arm64-lite.img
sudo losetup --show -f -P uc-bullseye-arm64-lite.img # assume /dev/loop0 below, parsed outpu in script
sudo mount /dev/loop0p2 /mnt/
sudo mount /dev/loop0p1 /mnt/boot/
sudo mount --bind /dev /mnt/dev/
sudo mount --bind /sys /mnt/sys/
sudo mount --bind /dev/pts /mnt/dev/pts/
sudo chroot /mnt # you are root in chroot after that, no sudo is needed
touch /boot/cmdline.txt # inc case it's missing, kernel package install breaks without it
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
sudo dd if=uc-bookworm-arm64-lite.img of=/dev/sdb status=progress bs=4M && sync

```

## Recent kernel package

See [here](kernel) for the .deb repack of the famous [kernel](https://forum.clockworkpi.com/t/archlinux-arm-for-uconsole-cm4-living-documentation/12804) by [@yatli](https://github.com/yatli)

## Resources:
- [uConsole github repo](https://github.com/clockworkpi/uConsole)
- [uConsole wiki](https://github.com/clockworkpi/uConsole/wiki)
- [clockworkPi community forum](https://forum.clockworkpi.com)

## External notes
- [uConsole Notes by @selfawaresoup](https://gist.github.com/selfawaresoup/b296f3b82167484a96e4502e74ed3602)
- [uConsole CM4 OS by @Snoozer-94](https://github.com/Snoozer-94/uConsole-CM4-OS)
- [My Clockwork uConsole Config Files by @krim404](https://github.com/krim404/uconsole_sway)
- [Kali linux image for uConsole cm4 by @clockworkpi](https://github.com/clockworkpi/uConsole/wiki/Kali-linux-image-for-uConsole-cm4)

## HW mods and extensions
- [μPico](https://github.com/dotcypress/upico) - RP2040 powered expansion card for GPIO
- [μHub](https://github.com/dotcypress/uhub) - USB Hub Expansion Card
- [3D printed front cover](https://www.printables.com/model/728066-solid-cover-antenna-mod-uconsole)

## Accessories
- Screen Protector (6K PRO) - ([ali](https://www.aliexpress.com/item/1005003758637657.html))
- 2x M4 Lanyard Screw D Ring ([ali](https://www.aliexpress.com/item/1005005830528136.htm))
- Micro SD Card Adapter Extender ([ali](https://www.aliexpress.com/item/1005004165611777.html))

## Notable links from clockworkpi community forum
- https://forum.clockworkpi.com/t/show-us-your-customised-uconsole/13732/15 - magnet wrench holder
- https://forum.clockworkpi.com/t/show-us-your-customised-uconsole/13732/33 - black anodized back cover
- https://forum.clockworkpi.com/t/uconsole-r01-poor-wifi-reception/13797 - wifi antenna polarisation changer
- https://forum.clockworkpi.com/t/uconsole-crashes-when-connecting-flipper-zero/13814/6 - power-toggle usb cable for flipper zero (and other stuff attemting to charge from uc)
- https://forum.clockworkpi.com/t/bookworm-6-6-y-for-the-uconsole-and-devterm/13235/164 - battery controller calibration
