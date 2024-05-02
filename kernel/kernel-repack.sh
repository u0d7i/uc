#!/bin/bash

Y_PKG="kernel-6.1-CM4-clockworkpi-DevTerm-uConsole-v2.tar.gz"
Y_URL="https://nextcloud.yatao.info:10443/s/8x9n86gZpENNgaz/download/${Y_PKG}"
PKG="uconsole-kernel-cm4-rpi_6.1.21-2_arm64.deb"

if [[ -e "${Y_PKG}" ]]; then
        echo "- ${Y_PKG} exists."
else
        echo "- ${Y_PKG} does not exist, downloading..."
        curl -o "${Y_PKG}" "${Y_URL}"
fi

echo "- creating package structure..."
rm -rf repack
mkdir -p repack/{DEBIAN,boot}
echo "- adding control..."
cat << EOF > repack/DEBIAN/control
Package: uconsole-kernel-cm4-rpi
Version: 6.1.21-2
Maintainer: user <user@localhost>
Architecture: arm64
Priority: optional
Conflicts: linux-image-rpi-v8
Provides: linux-image-rpi-v8
Replaces: linux-image-rpi-v8
Description: uconsole cm4 kernel
EOF

echo "- adding preinst..."
cat << EOF > repack/DEBIAN/preinst
#!/bin/sh

rm -rf /boot/bcm2711-rpi-cm4.dtb
rm -rf /boot/config.txt

rm -rf /boot/overlays
rm -rf /boot/kernel8.img
EOF
chmod +x repack/DEBIAN/preinst

echo "- adding posinst..."
cat << EOF > repack/DEBIAN/postinst
#!/bin/sh

sed -e "s/plymouth.ignore-serial-consoles//g" -i /boot/cmdline.txt
sed -e "s/quiet//g" -i /boot/cmdline.txt
sed -e "s/splash//g" -i /boot/cmdline.txt
EOF
chmod +x repack/DEBIAN/postinst

echo "- adding config.txt..."
cat << EOF > repack/boot/config.txt
disable_overscan=1
dtparam=audio=on
[pi4]
max_framebuffers=2

[all]
ignore_lcd=1
dtoverlay=dwc2,dr_mode=host
dtoverlay=vc4-kms-v3d-pi4,cma-384
dtoverlay=devterm-pmu
dtoverlay=devterm-panel-uc
dtoverlay=devterm-misc
dtoverlay=audremap,pins_12_13

dtparam=spi=on
gpio=10=ip,np
EOF

echo "- adding modules..."
tar -xf ${Y_PKG} --strip-components 1 -C repack modules/lib/modules
echo "- adding overlays..."
tar -xf ${Y_PKG} --strip-components 1 -C repack/boot out/overlays
echo "- adding dtb..."
tar -xf ${Y_PKG} --strip-components 1 -C repack/boot out/bcm2711-rpi-cm4.dtb
echo "- adding kernel..."
tar -xf ${Y_PKG} --strip-components 1 -C repack/boot out/kernel8.img

echo "- building .deb..."
fakeroot dpkg-deb -b repack "${PKG}"
