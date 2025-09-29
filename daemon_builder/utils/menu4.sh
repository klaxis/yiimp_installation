#!/usr/bin/env bash
#####################################################
# Updated by klaxis
# Updrade this scrypt
#####################################################

source /etc/daemonbuilder.sh
source $STORAGE_ROOT/daemon_builder/conf/info.sh

if [[ ("${LATESTVER}" > "${VERSION}" && "${LATESTVER}" != "null") ]]; then
	message_box " Updating This script to ${LATESTVER}" \
	"You are currently using version ${VERSION}
	\n\nAre you going to update it to the version ${LATESTVER}"
	TAG="${LATESTVER}"

	cd ~
	clear

	sudo git config --global url."https://github.com/".insteadOf git@github.com:
	sudo git config --global url."https://".insteadOf git://
	sleep 1

	REPO="klaxis/yiimp_installation"

	temp_dir="$(tempfile -d)" && \
		git clone -q git@github.com:${REPO%.git} "${temp_dir}" && \
			cd "${temp_dir}/" && \
				git -c advice.detachedHead=false checkout -q tags/${TAG}
	sleep 1
	test $? -eq 0 ||
		{ 
			echo
			echo -e "$RED Error cloning repository. $COL_RESET";
			echo
			sudo rm -f $temp_dir
			exit 1;
		}
	
	FILEINSTALLEXIST="${temp_dir}/install.sh"
	if [ -f "$FILEINSTALLEXIST" ]; then
		sudo chown -R $USER ${temp_dir}
		sleep 1
		cd ${temp_dir}
		sudo find . -type f -name "*.sh" -exec chmod -R +x {} \;
		sleep 1
		./install.sh "${temp_dir}"
	fi

	sudo rm -rf $temp_dir

	echo -e "$CYAN  -------------------------------------------------------------------------- 	$COL_RESET"
	echo -e "$GREEN    						Updating is Finish!					 				$COL_RESET"
	echo -e "$CYAN  -------------------------------------------------------------------------- 	$COL_RESET"
	echo
	cd ~
	exit

else
	message_box " Updating This script " \
	"Check if this scrypt needs update.
	\nyou already have the latest version installed!
	\nYour Version is: ${VERSION}"

	cd ~
	clear
	echo -e "$CYAN  -------------------------------------------------------------------------- 	$COL_RESET"
	echo -e "$RED    Thank you using this scrpt!			 				$COL_RESET"
	echo -e "$CYAN  -------------------------------------------------------------------------- 	$COL_RESET"
	echo
	echo -e "$CYAN  -------------------------------------------------------------------------- 	$COL_RESET"
	echo -e "$GREEN	Donations are welcome at wallets below:					  					$COL_RESET"
	echo -e "$YELLOW  BTC: $COL_RESET $MAGENTA ${BTCDEP}	$COL_RESET"
	echo -e "$YELLOW  LTC: $COL_RESET $MAGENTA ${LTCDEP}	$COL_RESET"
	echo -e "$YELLOW  ETH: $COL_RESET $MAGENTA ${ETHDEP}	$COL_RESET"
	echo -e "$YELLOW  BCH: $COL_RESET $MAGENTA ${DOGEDEP}	$COL_RESET"
	echo -e "$CYAN  -------------------------------------------------------------------------- 	$COL_RESET"
	echo
	cd ~
	exit

fi

