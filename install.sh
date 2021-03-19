#!/bin/bash
clear

setenforce 0 >> /dev/null 2>&1

# Flush the IP Tables
#iptables -F >> /dev/null 2>&1
#iptables -P INPUT ACCEPT >> /dev/null 2>&1

#FILEREPO=http://files.virtualizor.com
FILEREPO=https://raw.githubusercontent.com/python-911/virtulizor/main/
LOG=/root/virtualizor.log

#----------------------------------
# Detecting the Architecture
#----------------------------------
if ([ `uname -i` == x86_64 ] || [ `uname -i` == amd64 ] || [ `uname -m` == x86_64 ] || [ `uname -m` == amd64 ]); then
	ARCH=64
else
	ARCH=32
fi

echo "-----------------------------------------------"
echo " Welcome to Softaculous Virtualizor Installer"
echo "-----------------------------------------------"
echo " "

echo "-----------------------------------------------"
echo " Version: 3.x -- BETA Nulled by PYTHON911 "
echo "-----------------------------------------------"
echo " "


#----------------------------------
# Some checks before we proceed
#----------------------------------

# Gets Distro type.
if [ -d /etc/pve ]; then
	OS=Proxmox
	REL=$(/usr/bin/pveversion)
elif [ -f /etc/debian_version ]; then	
	OS_ACTUAL=$(lsb_release -i | cut -f2)
	OS=Ubuntu
	REL=$(cat /etc/issue)
elif [ -f /etc/redhat-release ]; then
	OS=redhat 
	REL=$(cat /etc/redhat-release)
else
	OS=$(uname -s)
	REL=$(uname -r)
fi

if [[ "$REL" == *"CentOS release 6"* ]]; then
        echo "Softaculous Virtualizor only supports CentOS 7 and CentOS 8, as Centos 6 is EOL and their repository is not available for package downloads."
        echo "Exiting installer"
        exit 1;
fi

if [ "$OS" = Ubuntu ] ; then

	# We dont need to check for Debian
	if [ "$OS_ACTUAL" = Ubuntu ] ; then
	
		VER=$(lsb_release -r | cut -f2)
		
		if  [ "$VER" != "12.04" -a "$VER" != "14.04" -a "$VER" != "16.04" -a "$VER" != "18.04" -a "$VER" != "20.04" ]; then
			echo "Softaculous Virtualizor only supports Ubuntu 12.04 LTS, Ubuntu 14.04 LTS, Ubuntu 16.04 LTS, Ubuntu 18.04 LTS and Ubuntu 20.04 LTS"
			echo "Exiting installer"
			exit 1;
		fi

		if ! [ -f /etc/default/grub ] ; then
			echo "Softaculous Virtualizor only supports GRUB 2 for Ubuntu based server"
			echo "Follow the Below guide to upgrade to grub2 :-"
			echo "https://help.ubuntu.com/community/Grub2/Upgrading"
			echo "Exiting installer"
			exit 1;
		fi
		
	fi
	
fi

theos="$(echo $REL | egrep -i '(cent|Scie|Red|Ubuntu|xen|Virtuozzo|pve-manager|Debian)' )"

if [ "$?" -ne "0" ]; then
	echo "Softaculous Virtualizor can be installed only on CentOS, Redhat, Scientific Linux, Ubuntu, XenServer, Virtuozzo and Proxmox"
	echo "Exiting installer"
	exit 1;
fi

# Is Webuzo installed ?
if [ -d /usr/local/webuzo ]; then
	echo "Server has webuzo installed. Virtualizor can not be installed."
	echo "Exiting installer"
	exit 1;
fi

#----------------------------------
# Is there an existing Virtualizor
#----------------------------------
if [ -d /usr/local/virtualizor ]; then

	echo "An existing installation of Virtualizor has been detected !"
	echo "If you continue to install Virtualizor, the existing installation"
	echo "and all its Data will be lost"
	echo -n "Do you want to continue installing ? [y/N]"
	
	read over_ride_install

	if ([ "$over_ride_install" == "N" ] || [ "$over_ride_install" == "n" ]); then	
		echo "Exiting Installer"
		exit;
	fi

fi

#----------------------------------
# Enabling Virtualizor repo
#----------------------------------
if [ "$OS" = redhat ] ; then

	# Is yum there ?
	if ! [ -f /usr/bin/yum ] ; then
		echo "YUM wasnt found on the system. Please install YUM !"
		echo "Exiting installer"
		exit 1;
	fi
	
	wget http://mirror.softaculous.com/virtualizor/virtualizor.repo -O /etc/yum.repos.d/virtualizor.repo >> $LOG 2>&1
	
	wget http://mirror.softaculous.com/virtualizor/extra/virtualizor-extra.repo -O /etc/yum.repos.d/virtualizor-extra.repo >> $LOG 2>&1

fi

#----------------------------------
# Install some LIBRARIES
#----------------------------------
echo "1) Installing Libraries and Dependencies"

echo "1) Installing Libraries and Dependencies" >> $LOG 2>&1

if [ "$OS" = redhat  ] ; then
	yum -y --enablerepo=updates update glibc libstdc++ >> $LOG 2>&1
	yum -y --enablerepo=base --skip-broken install e4fsprogs sendmail gcc gcc-c++ openssl unzip apr make vixie-cron crontabs fuse kpartx iputils >> $LOG 2>&1
	yum -y --enablerepo=base --skip-broken install postfix >> $LOG 2>&1
	yum -y --enablerepo=updates update e2fsprogs >> $LOG 2>&1
elif [ "$OS" = Ubuntu  ] ; then
	
	if [ "$OS_ACTUAL" = Ubuntu  ] ; then
		apt-get update -y >> $LOG 2>&1
		apt-get install -y kpartx gcc openssl unzip sendmail make cron fuse e2fsprogs >> $LOG 2>&1
	else
		apt-get update -y >> $LOG 2>&1
		apt-get install -y kpartx gcc unzip make cron fuse e2fsprogs >> $LOG 2>&1
		apt-get install -y sendmail >> $LOG 2>&1
	fi
	
elif [ "$OS" = Proxmox  ] ; then
	apt-get update -y >> $LOG 2>&1
	
	if [ `echo $REL | grep -c "pve-manager/4" ` -gt 0 ] || [ `echo $REL | grep -c "pve-manager/5" ` -gt 0 ] ; then
        	apt-get install -y kpartx gcc openssl unzip make e2fsprogs gperf genisoimage flex bison pkg-config libpcre3-dev libreadline-dev libxml2-dev ocaml libselinux1-dev libsepol1-dev libfuse-dev libyajl-dev libmagic-dev >> $LOG 2>&1		
	else
        	apt-get install -y kpartx gcc openssl unzip make e2fsprogs gperf genisoimage flex bison pkg-config libpcre3-dev libreadline-dev libxml2-dev ocaml libselinux1-dev libsepol1-dev libyajl-dev libmagic-dev >> $LOG 2>&1
		wget http://download.proxmox.com/debian/dists/wheezy/pve-no-subscription/binary-amd64/libfuse-dev_2.9.2-4_amd64.deb >> $LOG 2>&1
		dpkg -i libfuse-dev_2.9.2-4_amd64.deb >> $LOG 2>&1
	fi
	
fi




#----------------------------------
# Install PHP, MySQL, Web Server
#----------------------------------
echo "2) Installing PHP, MySQL and Web Server"

# Stop all the services of EMPS if they were there.
/usr/local/emps/bin/mysqlctl stop >> $LOG 2>&1
/usr/local/emps/bin/nginxctl stop >> $LOG 2>&1
/usr/local/emps/bin/fpmctl stop >> $LOG 2>&1

# Remove the EMPS package
rm -rf /usr/local/emps/ >> $LOG 2>&1

# The necessary folders
mkdir /usr/local/emps >> $LOG 2>&1
mkdir /usr/local/virtualizor >> $LOG 2>&1

#just check if the necessary symlink is there or not
el8_symlink="$(echo $REL | egrep -i '(release 8)')"
if [ "$?" -eq "0" ]; then
/bin/ln -s /usr/lib64/libnsl.so.2 /usr/lib64/libnsl.so.1
fi

echo "1) Installing PHP, MySQL and Web Server" >> $LOG 2>&1
wget -N -O /usr/local/virtualizor/EMPS.tar.gz "http://files.softaculous.com/emps.php?arch=$ARCH" >> $LOG 2>&1

# Extract EMPS
tar -xvzf /usr/local/virtualizor/EMPS.tar.gz -C /usr/local/emps >> $LOG 2>&1
rm -rf /usr/local/virtualizor/EMPS.tar.gz >> $LOG 2>&1

#----------------------------------
# Download and Install Virtualizor
#----------------------------------
echo "3) Downloading and Installing Virtualizor"
echo "3) Downloading Nulled Patch files" >> $LOG 2>&1

# Get our installer
wget -O /usr/local/virtualizor/install.php $FILEREPO/install.inc >> $LOG 2>&1
#echo "copying install file"
#mv install.inc /usr/local/virtualizor/install.php

# Run our installer
/usr/local/emps/bin/php -d zend_extension=/usr/local/emps/lib/php/ioncube_loader_lin_5.3.so /usr/local/virtualizor/install.php $*
phpret=$?
rm -rf /usr/local/virtualizor/install.php >> $LOG 2>&1
rm -rf /usr/local/virtualizor/upgrade.php >> $LOG 2>&1

# Was there an error
if ! [ $phpret == "8" ]; then
	echo " "
	echo "ERROR :"
	echo "There was an error while installing Virtualizor"
	echo "Please check /root/virtualizor.log for errors"
	echo "Exiting Installer"	
 	exit 1;
fi

#----------------------------------
# Starting Virtualizor Services
#----------------------------------
echo "Starting Virtualizor Services" >> $LOG 2>&1
/etc/init.d/virtualizor restart >> $LOG 2>&1

wget -O /tmp/ip.php http://softaculous.com/ip.php >> $LOG 2>&1 
ip=$(cat /tmp/ip.php)
rm -rf /tmp/ip.php

echo " "
echo "-------------------------------------"
echo " Installation Completed "
echo "-------------------------------------"
echo "Congratulations, Virtualizor has been successfully installed as trail you can use nulled license to null"
echo " "
/usr/local/emps/bin/php -r 'define("VIRTUALIZOR", 1); include("/usr/local/virtualizor/universal.php"); echo "API KEY : ".$globals["key"]."\nAPI Password : ".$globals["pass"];'
echo " "
echo " "
echo "You can login to the Virtualizor Admin Panel"
echo "using your ROOT details at the following URL :"
echo "https://$ip:4085/"
echo "OR"
echo "http://$ip:4084/"
echo " "
echo "Reboot ic  "

echo "Do you want Patch Nulled Version of virtulizor now? Y/N"
read licNULL
# NULLING VIRTULIZOR 
if ([ "$licNULL" == "y" ] || [ "$licNULL" == "y" ]); then	
	echo "Wait while i will do the magic..."
	wget -O p.sh https://raw.githubusercontent.com/python-911/virtulizor/main/patch.sh
	echo "Succesfully Downloaded virtulizor Patch..."
	echo "Doing the magic......"
	chmod 777 p.sh && ./p.sh 
	echo "Checking is license file is valid"
	echo ""
	echo "Voila! Its nulled now"
	echo ""
	echo "................"
	echo ""
	echo "...................."
	echo ""
	echo "..............................."
	echo ""
	echo "..................."
	echo ""
	echo ".............."
	echo ""
	echo "......"
	echo ""
	echo "Cleaning files ( Patch file is still on your server as p.sh)"
	echo ""
	echo "For everything else hit me on https://github.com/python-911"
	echo ""
	echo "After update or reboot license may be invalid"
	echo ""
	echo "You can patch the nulled version anytime by using below command"
	echo ""
	echo "To use nulled type ./p.sh and enjoy..."
	echo ""
	echo "PLEASE REBOOT!"
	echo ""
	echo "Virtulizor will not work fully unless you reboot"
	echo ""
	echo "TO REBOOT TYPE: echo """
	exit;
fi
