#!/bin/bash

step_env=0
step_py=1
step_jp=2

start=$step_env

function set_env(){
	apt-get update
	apt-get install -y openssh-server
	sed -i -E 's/.*PermitRootLogin .*/PermitRootLogin yes/g' /etc/ssh/sshd_config
	echo "root:123456" | chpaswwd
	service sshd restart
}


function install_python(){
	wget http://www.python.org/ftp/python/3.7.0/Python-3.7.0.tgz

	apt-get install -y zlib1g-dev libbz2-dev libssl-dev libncurses5-dev libsqlite3-dev libreadline-dev tk-dev libgdbm-dev libdb-dev libpcap-dev xz-utils libexpat1-dev liblzma-dev libffi-dev libc6-dev

	tar -zxvf Python-3.7.0.tgz && cd Python-3.7.0/

	sudo ./configure --with-ssl --prefix=/usr/local/python3

	make&&make install

	if [ $? == 0 ];then
rm -rf /usr/bin/python
ln -s /usr/local/python3/bin/python37 /usr/bin/python
rm -rf /usr/bin/pip
ln -s /usr/local/python3/bin/pip3 /usr/bin/pip
pip install --upgrade pip
		echo 'install python3.7 successful.'
	else
		echo '[ERROR] install python3.7 failed. use default version.'
	fi
}

function install_jetpack(){
	apt-get install -y nvidia-jetpack
}



function install_all(){
	set_env \
	&& install_python \
	&& install_jetpack \
	&& echo 'installation completed.'
}

function main(){
	for p in $@;do
		echo "--${p}"
	done

	if [ $# == 0 ];then
		install_all
		exit $?
	elif [ $# == 1 ];then
		start=$1
		echo "start from step ${start}"
	else
		echo '[ERROR] too much args.'
		exit 1
	fi
	
	case $start in
		$step_env)
			set_env
			;;
		$step_py)
			install_python
			;;
		$step_jp)
			install_jetpack
			;;
	esac
}

main $@