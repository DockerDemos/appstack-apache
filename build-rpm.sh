#!/bin/bash

set -x

RPMUSER='rpmbuilder'
RPMHOME="/home/$RPMUSER"
FPMSOURCE='https://github.com/clcollins/mod_fastcgi-rpm.git'
FPM='mod_fastcgi'

/usr/sbin/useradd $RPMUSER

/bin/mkdir -p $RPMHOME/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
/bin/echo '%_topdir %(echo $HOME)/rpmbuild' > $RPMHOME/.rpmmacros
/bin/chown -R $RPMUSER $RPMHOME

/bin/su -c "/usr/bin/git clone $FPMSOURCE $FPM" - rpmbuilder
/bin/su -c "/home/rpmbuilder/$FPM/build.sh $FPM 1>/dev/null" - rpmbuilder

/usr/bin/yum install -y $RPMHOME/rpmbuild/RPMS/*/*.rpm 

if [[ $? == 0 ]] ; then
  /usr/sbin/userdel $RPMUSER
  /bin/rm -rf $RPMHOME
fi
