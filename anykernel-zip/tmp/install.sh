#!/sbin/sh
BUSYBOX="/tmp/busybox"
LZ4="/tmp/lz4"

mkdir /tmp/out

dd if=/dev/block/platform/msm_sdcc.1/by-name/boot of=/tmp/boot.img || exit 1
if [ -z /tmp/boot.img ]; then exit 1; fi

/tmp/unpackbootimg -i /tmp/boot.img -o /tmp/out

mkdir /tmp/out_ramfs
cd /tmp/out_ramfs

if [ -e /tmp/out/boot.img-ramdisk.gz ]; then
	rdcomp=/tmp/out/boot.img-ramdisk.gz
	$BUSYBOX gzip -d -c "$rdcomp" | $BUSYBOX cpio -i
elif [ -e /tmp/out/boot.img-ramdisk.lz4 ]; then
	rdcomp=/tmp/out/boot.img-ramdisk.lz4
	$LZ4 -d "$rdcomp" stdout | $BUSYBOX cpio -i
else
	exit 1
fi

# <name_of_your_script> Starting Script
found=$(find init.qcom.rc -type f | xargs grep -oh "# <name_of_your_script> start");
if [ "$found" != '# <name_of_your_script> start' ]; then
sed -e '/# CM Performance Profiles/,/    write \/sys\/class\/devfreq\/qcom,cpubw.65 performance/c\# <name_of_your_script> start' -i init.qcom.rc;
echo "# <name_of_your_script> start" >> init.qcom.rc;
echo "on property:sys.boot_completed=1" >> init.qcom.rc;
echo "exec <name_of_your_script>.sh" >> init.qcom.rc;
echo "# <name_of_your_script> end" >> init.qcom.rc;
fi;

# make kernel open
cp -vr ../extras/default.prop .
cp -vr ../extras/<name_of_your_script>.sh .

chmod -R 755 /tmp/out_ramfs

rm $rdcomp

case $rdcomp in
	/tmp/out/boot.img-ramdisk.gz)
		find . | $BUSYBOX cpio -o -H newc | $BUSYBOX gzip > "$rdcomp"
		;;
	/tmp/out/boot.img-ramdisk.lz4)
		find . | $BUSYBOX cpio -o -H newc | $LZ4 stdin "$rdcomp"
		;;
esac

/tmp/mkbootimg --kernel /tmp/kernel/zImage --ramdisk $rdcomp --dt /tmp/kernel/dt.img --cmdline "$(cat /tmp/cmdline)" --pagesize $(cat /tmp/out/boot.img-pagesize) --base $(cat /tmp/out/boot.img-base) --ramdisk_offset $(cat /tmp/out/boot.img-ramdisk_offset) --tags_offset $(cat /tmp/out/boot.img-tags_offset) --output /tmp/newboot.img

if [ -z /tmp/newboot.img ]; then exit 1; fi

dd if=/tmp/bump >> /tmp/newboot.img
dd if=/dev/zero of=/dev/block/platform/msm_sdcc.1/by-name/boot
dd if=/tmp/newboot.img of=/dev/block/platform/msm_sdcc.1/by-name/boot

exit 0
