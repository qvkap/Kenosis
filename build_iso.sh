#!/bin/sh -e
apk add --no-cache syslinux xorriso mtools ncurses-dev flex bison elfutils-dev openssl-dev
curl -sL https://mirrors.kernel.org/pub/linux/kernel/v6.x/linux-6.10.3.tar.xz | tar -xJ
cd linux-6.10.3

unset CC

make defconfig
sed -i 's/CONFIG_MODULES=y/# CONFIG_MODULES is not set/' .config
sed -i 's/CONFIG_DRM=y/# CONFIG_DRM is not set/' .config
make olddefconfig
make -j$(nproc) bzImage

mkdir -p /iso/boot/syslinux
cp arch/x86/boot/bzImage /iso/boot/vmlinuz

cd /mnt/rootfs
find . | cpio -o -H newc | gzip -9 > /iso/boot/initramfs.igz

echo "DEFAULT kenosis" > /iso/boot/syslinux/syslinux.cfg
echo "LABEL kenosis" >> /iso/boot/syslinux/syslinux.cfg
echo "  LINUX /boot/vmlinuz" >> /iso/boot/syslinux/syslinux.cfg
echo "  INITRD /boot/initramfs.igz" >> /iso/boot/syslinux/syslinux.cfg
echo "  APPEND root=/dev/ram0 console=ttyS0 quiet init=/init" >> /iso/boot/syslinux/syslinux.cfg

cp /usr/share/syslinux/isolinux.bin /iso/boot/syslinux/
cp /usr/share/syslinux/ldlinux.c32 /iso/boot/syslinux/

xorriso -as mkisofs \
  -o $GITHUB_WORKSPACE/kenosis-base-x86_64.iso \
  -b boot/syslinux/isolinux.bin \
  -c boot/syslinux/boot.cat \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  /iso

cd $GITHUB_WORKSPACE
