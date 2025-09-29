#!/bin/bash
################################################################################
#
#   Install Stratum OR Update on Ubuntu 18.04/20.04
#   v0.1 (update December, 2022)
#
################################################################################

	clear

	output() {
	printf "\E[0;33;40m"
	echo $1
	printf "\E[0m"
	}

	displayErr() {
	echo
	echo $1;
	echo
	exit 1;
	}
	
	whoami=`whoami`

	source /etc/daemonbuilder.sh

	source $HOME/${installtoserver}/conf/coin.sh
	term_art

	echo
	echo
	echo -e "$RED Install Straum OR update!! $COL_RESET"
	echo

	# Installing Stratum
	echo
	echo
	echo -e "$MAGENTA => Installing Stratum $COL_RESET"
	echo
	echo -e "Grabbing Stratum fron Github, building files and setting file structure."
	echo
	sleep 3

	# Compil Blocknotify
	cd ~
	git clone https://github.com/klaxis/yiimp/tree/main/stratum
	sudo chmod -R 777 $HOME/stratum/
	cd $HOME/stratum/blocknotify
	sudo sed -i 's/tu8tu5/'$PASSWORD_STRATUM'/' blocknotify.cpp
	sudo make -j$(nproc)
	sleep 3

	# Compil iniparser
	cd $HOME/stratum
	sudo make -C iniparser/ -j$(nproc)
	sleep 3

	# Compil algos
	sudo make -C algos/ -j$(nproc)
	sleep 3

	# Compil sha3
	sudo make -C sha3 -j$(nproc)
	sleep 3
	
	whoami=`whoami`
	echo
	echo -e "$RED Enter password for ROOT server : $COL_RESET"
	echo
	su root
	cd $HOME/$whoami/${installtoserver}/stratum
	
	# Compil stratum
	sudo make -f Makefile -j$(nproc)
	sleep 3
	
	su $whoami
	cd $HOME/stratum

	# Copy Files (Blocknotify,iniparser,Stratum)
	sudo mkdir -p /home/crypto-data/yiimp/site/stratum
	sudo cp -a config.sample/. /home/crypto-data/yiimp/site/stratum/config
	sudo cp -r stratum /home/crypto-data/yiimp/site/stratum
	sudo cp -r run.sh /home/crypto-data/yiimp/site/stratum
	sudo cp -r $HOME/stratum/bin/. /bin/
	sudo cp -r $HOME/stratum/blocknotify/blocknotify /usr/bin/
	sudo cp -r $HOME/stratum/blocknotify/blocknotify /home/crypto-data/yiimp/site/stratum/
	sleep 3
	
	#fixing run.sh
	sudo rm -r /home/crypto-data/yiimp/site/stratum/config/run.sh
	echo '
	#!/bin/bash
	ulimit -n 10240
	ulimit -u 10240
	cd /home/crypto-data/yiimp/site/stratum
	while true; do
	./stratum /home/crypto-data/yiimp/site/stratum/config/$1
	sleep 2
	done
	exec bash
	' | sudo -E tee /home/crypto-data/yiimp/site/stratum/config/run.sh >/dev/null 2>&1
	sudo chmod +x /home/crypto-data/yiimp/site/stratum/config/run.sh

	echo -e "$GREEN Done...$COL_RESET"
	sleep 3

	# Update Timezone
	echo
	echo
	echo -e "$CYAN => Update default timezone. $COL_RESET"
	echo

	echo -e " Setting TimeZone to UTC...$COL_RESET"
	if [ ! -f /etc/timezone ]; then
	echo "Setting timezone to UTC."
	echo "Etc/UTC" > sudo /etc/timezone
	sudo systemctl restart rsyslog
	fi
	sudo systemctl status rsyslog | sed -n "1,3p"
	echo
	echo -e "$GREEN Done...$COL_RESET"
	sleep 3

	# Updating stratum config files with database connection info
	echo
	echo
	echo -e "$CYAN => Updating stratum config files with database connection info. $COL_RESET"
	echo
	sleep 3

	cd /home/crypto-data/yiimp/site/stratum/config
	sudo sed -i 's/password = tu8tu5/password = '$PASSWORD_STRATUM'/g' *.conf
	sudo sed -i 's/server = yaamp.com/server = '$SERVER_STRATUM'/g' *.conf
	sudo sed -i 's/host = yaampdb/host = '$SERVER_STRATUM'/g' *.conf
	sudo sed -i 's/database = yaamp/database = '$MYSQL_DATABASE'/g' *.conf
	sudo sed -i 's/username = root/username = '$MYSQL_USER'/g' *.conf
	sudo sed -i 's/password = patofpaq/password = '$MYSQL_PASSWORD'/g' *.conf
	cd ~
	echo -e "$GREEN Done...$COL_RESET"

	# Final Directory permissions
	echo
	echo
	echo -e "$CYAN => Final Directory permissions $COL_RESET"
	echo
	sleep 3

	sudo chgrp www-data /home/crypto-data/yiimp/site/stratum -R
	sudo chmod 775 /home/crypto-data/yiimp/site/stratum

	#Misc
	sudo rm -rf $HOME/stratum-install-finish
	sudo mv $HOME/stratum/ $HOME/stratum-install-finish

	echo
	echo -e "$GREEN Done...$COL_RESET"
	sleep 3

	echo
	install_end_message
	echo
	echo
	cd ~