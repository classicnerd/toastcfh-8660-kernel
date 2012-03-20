#!/bin/bash

# Copyright (C) 2011 Twisted Playground

# This script is designed to compliment .bash_profile code to automate the build process by adding a typical shell command such as:
# function buildKernel { echo "Ace, Mecha, Sholes, Release?"; read device; cd /Volumes/android/android-tzb_ics4.0.1/kernel;  ./buildChosenKernel.sh $device; }
# This script is designed by Twisted Playground for use on MacOSX 10.7 but can be modified for other distributions of Mac and Linux

PROPER=`echo $2 | sed 's/\([a-z]\)\([a-zA-Z0-9]*\)/\u\1\2/g'`

HANDLE=TwistedZero
KERNELSPEC=/Volumes/android/toastcfh-8660-kernel
ANDROIDREPO=/Volumes/android/Twisted-Playground
DROIDGITHUB=TwistedUmbrella/Twisted-Playground.git
SHOOTREPO=/Volumes/android/github-aosp_source/android_device_htc_shooter
SHOOTGITHUB=TwistedPlayground/android_device_htc_shooter.git

make clean -j$CPU_JOB_NUM

CPU_JOB_NUM=16
TOOLCHAIN_PREFIX=arm-none-eabi-

make -j$CPU_JOB_NUM ARCH=arm CROSS_COMPILE=$TOOLCHAIN_PREFIX

find . -name "*.ko" | xargs ${TOOLCHAIN_PREFIX}strip --strip-unneeded

if [ "$2" == "shooter" ]; then

echo "adding to build"

if [ ! -e $SHOOTREPO/kernel ]; then
mkdir $SHOOTREPO/kernel
fi
if [ ! -e $SHOOTREPO/kernel/lib ]; then
mkdir $SHOOTREPO/kernel/lib
fi
if [ ! -e $SHOOTREPO/kernel/lib/modules ]; then
mkdir $SHOOTREPO/kernel/lib/modules
fi

cp -R arch/arm/boot/zImage $SHOOTREPO/kernel/kernel
for j in $(find . -name "*.ko"); do
cp "${j}" $SHOOTREPO/kernel/lib/modules
done

if [ -e $SHOOTREPO/kernel/kernel ]; then
cd $SHOOTREPO
git commit -a -m "Automated Kernel Update - ${PROPER}"
git push git@github.com:$SHOOTGITHUB HEAD:ics
fi

else

rm -fr tmpdir
mkdir tmpdir
cp arch/arm/boot/zImage tmpdir/
for j in $(find . -name "*.ko"); do
    cp "${j}" tmpdir/
done

cp -a anykernel.tpl tmpdir/anykernel
mkdir -p tmpdir/anykernel/kernel
mkdir -p tmpdir/anykernel/system/lib/modules
cp tmpdir/zImage tmpdir/anykernel/kernel
for j in tmpdir/*.ko; do
    cp "${j}" tmpdir/anykernel/system/lib/modules/
done

echo "making zip file"
cd tmpdir/anykernel
zip -r "TwistedZero_toastcfh-hijack_ICS.zip" *
cp -R TwistedZero_toastcfh-hijack_ICS.zip $ANDROIDREPO/Kernel
cd ../../
rm -fr tmpdir
cd $ANDROIDREPO
git checkout gh-pages
git commit -a -m "Automated Shooter Kernel Build - Patch"
git push git@github.com:$DROIDGITHUB HEAD:ics

fi

cd $KERNELSPEC