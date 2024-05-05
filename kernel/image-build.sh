#!/bin/bash

BASE_IMG="2024-03-15-raspios-bookworm-arm64-lite.img.xz"
BASE_URL="https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2024-03-15/2024-03-15-raspios-bookworm-arm64-lite.img.xz"
IMG="uc-cm4-bookworm-arm64-lite.img"
PKG="uconsole-kernel-cm4-rpi_6.1.21-2_arm64.deb"

if [[ -e "${IMG}" ]]; then
	echo "- image found."
else
	echo "- image not found."
	if [[ -e "${BASE_IMG}" ]]; then
	       	echo "- base image found."
	else
		echo "- base image not found, downloading..."
		curl -o "${BASE_IMG}" "${BASE_URL}"
	fi
	echo "- unpacking..."
	xz -dcfv "${BASE_IMG}" > "${IMG}"
fi

LOOP=$(losetup -a | grep img | cut -d: -f1)
if [[ -z "${LOOP}" ]]; then
	echo "- setting loop device..."
	LOOP=$(sudo losetup --show -f -P ${IMG})
else
	echo "- loop device already set."
fi
if mount | grep "${LOOP}" | grep -q "/mnt"; then
	echo "- /mnt already mounted."
else
	echo "- mounting under /mnt..."
	sudo mount ${LOOP}p2 /mnt
	sudo mount ${LOOP}p1 /mnt/boot
	sudo mount --bind /dev /mnt/dev/
	sudo mount --bind /sys /mnt/sys/
	sudo mount --bind /dev/pts /mnt/dev/pts/
fi

echo "- altering image..."
sudo sed -i 's/gb/us/' /mnt/etc/default/keyboard
[[ -e "${PKG}" ]] && sudo cp ${PKG} /mnt/
[[ -e "/mnt/${PKG}" ]] && sudo chroot /mnt dpkg -i /${PKG}
echo "- interactive chroot shell, exit to continue"
sudo chroot /mnt
echo "- cleaning up..."
sudo rm -f /mnt/root/.bash_history
sudo umount -R /mnt
sudo losetup -D
