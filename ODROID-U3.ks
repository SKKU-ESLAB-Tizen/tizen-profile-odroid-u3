# -*-mic2-options-*- -f loop --pack-to=@NAME@.tar.gz -*-mic2-options-*-

# 
# Do not Edit! Generated by:
# kickstarter.py
# 

lang en_US.UTF-8
keyboard us
timezone --utc America/Los_Angeles
# ROOT fs partition
part / --size=3000 --ondisk mmcblk0p --fstype=ext4 --label=platform
# DATA partition
part /opt/ --size=3000 --ondisk mmcblk0p --fstype=ext4 --label=data
# UMS partition
part /opt/usr/ --size=3000 --ondisk mmcblk0p --fstype=ext4 --label=ums

rootpw tizen 
bootloader  --timeout=0  --append="rootdelay=5"   

desktop --autologinuser=root  
user --name root  --groups audio,video --password ''

repo --name=local --baseurl=file:///home/redcarrottt/GBS-ROOT/local/repos/tizen2.2/armv7l/ --priority=1
repo --name=Tizen-2.2-main --baseurl=http://download.tizen.org/snapshots/2.2/common/latest/repos/tizen-main/armv7l/packages/ --save --priority=2
repo --name=Tizen-2.2-base --baseurl=http://download.tizen.org/snapshots/2.2/common/latest/repos/tizen-base/armv7l/packages/ --save --priority=3

%packages

@common
@apps-common
@apps-core
@osp
@target-common
@target-odroid-u3


%end

%prepackages
eglibc
systemd
busybox
libacl
libcap
dbus-libs
libgcc
libudev
libattr
default-files-tizen
openssl
libprivilege-control
libprivilege-control-conf
security-server
libdlog
libsecurity-server-client
sqlite
tzdata-slp
vconf
tizen-coreutils
rpm-security-plugin
%end


%post
echo 'kickstart post script start'
if [ -d /etc/init.d ]; then
    cp /etc/init.d/* /etc/rc.d/init.d/ -rdf
fi
rm -rf /etc/init.d*
ln -sf /etc/rc.d/init.d /etc/init.d

rm -rf /etc/localtime  
ln -sf /opt/etc/localtime /etc/localtime  
#rm -rf /usr/share/zoneinfo  
#ln -sf /opt/share/zoneinfo /usr/share/zoneinfo 

ssh-keygen -t rsa1 -f /etc/ssh/ssh_host_key -N ""
ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -N ""
ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ""

pkg_initdb

INITDB=1 ail_initdb

# ims-service domain setting
RESULT=`grep "192.168.0.163 config.45001.rcse" /etc/hosts`  
if [ -z "$RESULT" ]; then  
    echo "Set domain for auto configuration"  
    echo "192.168.0.163 config.45001.rcse" >> /etc/hosts  
else  
    echo "Already setted domain for test auto configuration"  
fi  
# ims-service domain setting

cat > /usr/bin/press << EOF
#!/bin/sh

JUNK="SLP"

[ "\$1" ] && TIMEOUT="\$1" || TIMEOUT="1"

echo "Press return key to stop scripts"
read -t \$TIMEOUT JUNK
exit \$?
EOF
chmod +x /usr/bin/press

# [systemd] we need suid-root X for it to work from user-session
#           Xorg will move to system, so this is temporary
chmod 4755 /usr/bin/Xorg

ln -s /opt/etc/X11/xkb /usr/share/X11

echo "UDEV_PERSISTENT_STORAGE=no" >> /etc/sysconfig/udev

# for QA
mv /usr/include/python2.7/pyconfig.h /usr/pyconfig.h
rm -rf /usr/include/*
mkdir -p /usr/include/python2.7
mv /usr/pyconfig.h /usr/include/python2.7/pyconfig.h
#rm -rf /usr/include
rm -rf /usr/share/man
rm -rf /usr/share/doc

ldconfig

mkdir -p /opt/var/lib/dbus


# read-writeable /var will be bind-mounted to /opt/var leaving rootfs read-only
# below script more generic

rm -f /var/lib/rpm/__db*
rpm --rebuilddb
cp -a /var /opt/
rm -rf /var
mkdir /var


# [systemd] some firstboot script like kbd could be done to image-creatation stage
#           this patch is for it.
for i in /etc/preconf.d/*; do
    $i
done

if [ -e /usr/bin/build-backup-data.sh ]; then
           /usr/bin/build-backup-data.sh
fi

ln -sf /etc/info.ini /opt/etc/info.ini
ln -sf /etc/info.ini /usr/etc/info.ini

# Without this line the rpm don't get the architecture right.
echo -n 'armv7l-tizen-linux' > /etc/rpm/platform


/etc/make_info_file.sh Ref.Device-ODROID-U3 Tizen_Ref.Device-ODROID-U3_`date +%Y%m%d.%H%M`



%end

%post --nochroot
if [ -f /etc/device-sec-policy ]; then
	cp -fp /etc/device-sec-policy $INSTALL_ROOT/etc/
fi

if [ -d /etc/smack/accesses.d ]; then
	mkdir -p $INSTALL_ROOT/opt/etc/smack/accesses.d
	cp -rfp /etc/smack/accesses.d/* $INSTALL_ROOT/opt/etc/smack/accesses.d/
fi


%end