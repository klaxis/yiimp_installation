#!/usr/bin/env bash
#########################################################
# Source https://mailinabox.email/ https://github.com/mail-in-a-box/mailinabox
# Updated by ikatheria for Yiimpool use...
# This script is intended to be run like this:
#
# curl https://raw.githubusercontent.com/ikatheria/yiimp_installation/master/install.sh | bash
#
#########################################################

if [ -z "${TAG}" ]; then
	TAG=v0.9.3
fi

echo 'VERSION='"${TAG}"'' | sudo -E tee /etc/yiimpoolversion.conf >/dev/null 2>&1

# Clone the Yiimp Install Script repository if it doesn't exist.
if [ ! -d $HOME/yiimp_installation ]; then
	if [ ! -f /usr/bin/git ]; then
		echo Installing git . . .
		apt-get -q -q update
		DEBIAN_FRONTEND=noninteractive apt-get -q -q install -y git < /dev/null
		clear
		echo

	fi
	
	echo Downloading Yiimpool Installer ${TAG}. . .
	git clone \
		-b ${TAG} --depth 1 \
		https://github.com/ikatheria/yiimp_installation \
		"$HOME"/yiimp_installation \
		< /dev/null 2> /dev/null

	echo
fi


cd $HOME/yiimp_installation/

# Update it.
sudo chown -R $USER $HOME/yiimp_installation/.git/
if [ "${TAG}" != `git describe --tags` ]; then
	echo Updating Yiimpool Installer to ${TAG} . . .
	git fetch --depth 1 --force --prune origin tag ${TAG}
	if ! git checkout -q ${TAG}; then
		echo "Update failed. Did you modify something in `pwd`?"
		exit
	fi
	echo
fi

# Start setup script.
bash $HOME/yiimp_installation/install/start.sh
