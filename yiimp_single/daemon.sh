#!/usr/bin/env bash

##########################################
# Created by klaxis for Yiimpool use... #
##########################################

source /etc/functions.sh
source /etc/yiimpool.conf
source $STORAGE_ROOT/yiimp/.yiimp.conf
source $HOME/yiimp_installation/yiimp_single/.wireguard.install.cnf

set -eu -o pipefail

function print_error {
  read line file <<<$(caller)
  echo "An error occurred in line $line of file $file:" >&2
  sed "${line}q;d" "$file" >&2
}
trap print_error ERR
term_art
echo -e "$MAGENTA    <----------------------------------------------------->$COL_RESET"
echo -e "$MAGENTA     <--$YELLOW Installing Berkeley , openssl , bls-signatures$MAGENTA -->$COL_RESET"
echo -e "$MAGENTA    <----------------------------------------------------->$COL_RESET"
echo

echo -e "$YELLOW => Installing BitCoin PPA <= $COL_RESET"
if [ ! -f /etc/apt/sources.list.d/bitcoin.list ]; then
  sudo add-apt-repository -y ppa:bitcoin/bitcoin
fi
echo
echo -e "$YELLOW => Installing additional system files required for daemons <= $COL_RESET"
sudo apt-get update
sudo apt -y install build-essential libtool autotools-dev \
  automake pkg-config libssl-dev libevent-dev bsdmainutils git libboost-all-dev libminiupnpc-dev \
  libqt5gui5 libqt5core5a libqt5webkit5-dev libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev \
  protobuf-compiler libqrencode-dev libzmq3-dev libgmp-dev

sudo mkdir -p $STORAGE_ROOT/yiimp/yiimp_setup/tmp
cd $STORAGE_ROOT/yiimp/yiimp_setup/tmp
echo
echo -e "$GREEN => Additional System Files Completed  <= $COL_RESET"

echo
echo -e "$MAGENTA => Building Berkeley 4.8, this may take several minutes <= $COL_RESET"
sudo mkdir -p $STORAGE_ROOT/berkeley/db4/
sudo wget 'http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz'
sudo tar -xzvf db-4.8.30.NC.tar.gz
cd db-4.8.30.NC/build_unix/
sed -i 's/__atomic_compare_exchange/__atomic_compare_exchange_db/g' dbinc/atomic.h
sudo ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=$STORAGE_ROOT/berkeley/db4/
sudo make -j$((`nproc`+1))
cd $STORAGE_ROOT/yiimp/yiimp_setup/tmp
sudo rm -r db-4.8.30.NC.tar.gz db-4.8.30.NC
echo
echo -e "$GREEN => Berkeley 4.8 Completed <= $COL_RESET"
echo

echo -e "$MAGENTA => Building Berkeley 5.1, this may take several minutes <= $COL_RESET"
echo
sudo mkdir -p $STORAGE_ROOT/berkeley/db5/
sudo wget 'http://download.oracle.com/berkeley-db/db-5.1.29.tar.gz'
sudo tar -xzvf db-5.1.29.tar.gz
cd db-5.1.29/build_unix/
sed -i 's/__atomic_compare_exchange/__atomic_compare_exchange_db/g' dbinc/atomic.h
sudo ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=$STORAGE_ROOT/berkeley/db5/
sudo make -j$((`nproc`+1))
cd $STORAGE_ROOT/yiimp/yiimp_setup/tmp
sudo rm -r db-5.1.29.tar.gz db-5.1.29
echo -e "$GREEN => Berkeley 5.1 Completed <= $COL_RESET"
echo
echo -e "$MAGENTA => Building Berkeley 5.3, this may take several minutes <= $COL_RESET"
echo
sudo mkdir -p $STORAGE_ROOT/berkeley/db5.3/
sudo wget 'http://anduin.linuxfromscratch.org/BLFS/bdb/db-5.3.28.tar.gz'
sudo tar -xzvf db-5.3.28.tar.gz
cd db-5.3.28/build_unix/
sed -i 's/__atomic_compare_exchange/__atomic_compare_exchange_db/g' dbinc/atomic.h
sudo ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=$STORAGE_ROOT/berkeley/db5.3/
sudo make -j$((`nproc`+1))
cd $STORAGE_ROOT/yiimp/yiimp_setup/tmp
sudo rm -r db-5.3.28.tar.gz db-5.3.28
echo -e "$GREEN => Berkeley 5.3 Completed <= $COL_RESET"
echo
echo -e "$YELLOW Building Berkeley 6.2, this may take several minutes...$COL_RESET"
echo
sudo mkdir -p $STORAGE_ROOT/berkeley/db6.2/
sudo wget 'https://download.oracle.com/berkeley-db/db-6.2.23.tar.gz'
sudo tar -xzvf db-6.2.23.tar.gz
cd db-6.2.23/build_unix/
sed -i 's/__atomic_compare_exchange/__atomic_compare_exchange_db/g' dbinc/atomic.h
sudo ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=$STORAGE_ROOT/berkeley/db6.2/
sudo make -j$((`nproc`+1))
cd $STORAGE_ROOT/yiimp/yiimp_setup/tmp
sudo rm -r db-6.2.23.tar.gz db-6.2.23
echo -e "$GREEN => Berkeley 6.2 Completed <= $COL_RESET"
echo
echo -e "$YELLOW Building Berkeley 18, this may take several minutes...$COL_RESET"
echo
sudo mkdir -p $STORAGE_ROOT/berkeley/db18/
sudo wget 'https://download.oracle.com/berkeley-db/db-18.1.40.tar.gz'
sudo tar -xzvf db-18.1.40.tar.gz
cd db-18.1.40/build_unix/
sed -i 's/__atomic_compare_exchange/__atomic_compare_exchange_db/g' dbinc/atomic.h
sudo ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=$STORAGE_ROOT/berkeley/db18/
sudo make -j$((`nproc`+1))
cd $STORAGE_ROOT/yiimp/yiimp_setup/tmp
sudo rm -r db-18.1.40.tar.gz db-18.1.40
echo -e "$GREEN => Berkeley 18 Completed <= $COL_RESET"
echo

echo -e "$YELLOW => Building OpenSSL 1.0.2g, this may take several minutes <= $COL_RESET"
echo
cd $STORAGE_ROOT/yiimp/yiimp_setup/tmp
sudo wget https://www.openssl.org/source/old/1.0.2/openssl-1.0.2g.tar.gz --no-check-certificate
sudo tar -xf openssl-1.0.2g.tar.gz
cd openssl-1.0.2g
sudo ./config --prefix=$STORAGE_ROOT/openssl --openssldir=$STORAGE_ROOT/openssl shared zlib
sudo make -j$((`nproc`+1))
sudo make install -j$((`nproc`+1))
cd $STORAGE_ROOT/yiimp/yiimp_setup/tmp
sudo rm -r openssl-1.0.2g.tar.gz openssl-1.0.2g
echo -e "$GREEN =>OpenSSL 1.0.2g Completed <= $COL_RESET"
echo

echo -e "$YELLOW => Building bls-signatures, this may take several minutes <= $COL_RESET"
cd $STORAGE_ROOT/yiimp/yiimp_setup/tmp
sudo wget 'https://github.com/codablock/bls-signatures/archive/v20181101.zip'
sudo unzip v20181101.zip
cd bls-signatures-20181101
sudo cmake .
sudo make install -j$((`nproc`+1))
cd $STORAGE_ROOT/yiimp/yiimp_setup/tmp
sudo rm -r v20181101.zip bls-signatures-20181101
echo
echo -e "$GREEN => bls-signatures Completed$COL_RESET"

echo
echo -e "$YELLOW => Building blocknotify.sh <= $COL_RESET"
if [[ ("$wireguard" == "true") ]]; then
  source $STORAGE_ROOT/yiimp/.wireguard.conf
  echo '#####################################
  # Created by klaxis for Yiimpool use...  #
  ###########################################
  #!/bin/bash
  blocknotify '""''"${DBInternalIP}"''""':$1 $2 $3' | sudo -E tee /usr/bin/blocknotify.sh >/dev/null 2>&1
  sudo chmod +x /usr/bin/blocknotify.sh
else
  echo '#####################################
  # Created by klaxis for Yiimpool use...  #
  ###########################################
  #!/bin/bash
  blocknotify 127.0.0.1:$1 $2 $3' | sudo -E tee /usr/bin/blocknotify.sh >/dev/null 2>&1
  sudo chmod +x /usr/bin/blocknotify.sh
fi

echo
echo -e "$GREEN Daemon setup completed $COL_RESET"

set +eu +o pipefail
cd $HOME/yiimp_installation/yiimp_single
