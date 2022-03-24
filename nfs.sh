#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
	echo "Error: You must be root to run this script, please use root to install nfs"
	exit 1
fi

echo "Remember to install server && add client first, then mount client."

cur_dir=$(pwd)

Install_NFS()
{
	yum install nfs* -y
	service rpcbind start
	chkconfig rpcbind on
	service nfs start
	chkconfig nfs on
}

Add_Client()
{
	Echo_Yellow "Where to share?(default: /data)"
	read -p "You choose:" location
	if [ "$location" == "" ]; then
		location="/data"
	fi

	Echo_Yellow "What is ip do you want to share?(default: 0.0.0.0)"
	read -p "You choose:" ip
	if [ "${ip}" == "" ]; then
		ip="0.0.0.0"
	fi

	if [ ! -d "${location}" ]; then
		mkdir "${location}"
	fi

	chmod 777 "${location}"
	echo "${location} ${ip}(rw,sync,no_root_squash,no_all_squash)" >> /etc/exports
	echo "Mkdir successed, now restart nfs..."
	service nfs restart
	echo "OK, enjoy it"
}

Mount_server()
{
	Echo_Yellow "Where to share?(default: /data)"
	read -p "You choose:" location
	if [ "$location" == "" ]; then
		location="/data"
	fi

	if [ ! -d "${location}" ]; then
		mkdir "${location}"
	fi
	chmod 777 "${location}"

	Echo_Yellow "What is ip is nfs server?(default: 0.0.0.0)"
	read -p "You choose:" ip 
	if [ "${ip}" == "" ]; then
		ip="0.0.0.0"
	fi

	Echo_Yellow "What is nfs server share folder?(default: /data)"
	read -p "You choose:" server_location

	if [ "$location" == "" ]; then
		server_location="/data"
	fi

	mount -t nfs "${ip}":"${server_location}" "${location}"
	echo "Mount successed, now restart nfs..."
	service nfs restart
	echo "OK, enjoy it."
}

Color_Text()
{
	echo -e " \e[0;$2m$1\e[0m"
}

Echo_Red()
{
	echo $(Color_Text "$1" "31")
}

Echo_Green()
{
	echo $(Color_Text "$1" "32")
}

Echo_Yellow()
{
	echo $(Color_Text "$1" "33")
}

Echo_Blue()
{
	echo $(Color_Text "$1" "34")
}

Echo_Yellow "What do you want to do?"
echo "1: Install nfs server"
echo "2: Add nfs client for server"
echo "3: Install nfs client"
echo "default: Install nfs server"

read -p "You choose: " router


case "${router}" in
	1)	
		Install_NFS
		Add_Client
		;;
	2)
		Add_Client
		;;
	3)
		Install_NFS
		Mount_server
		;;
	*)
		Echo_Red "Usage: please select"
		;;
esac
