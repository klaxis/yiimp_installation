#!/usr/bin/env bash

#####################################################
# Source various web sources:
# https://www.linuxbabe.com/ubuntu/enable-google-tcp-bbr-ubuntu
# https://www.cyberciti.biz/faq/linux-tcp-tuning/
# Created by Afiniel for Yiimpool use...
#####################################################

source /etc/functions.sh
source /etc/yiimpool.conf

echo
echo -e "$GREEN => Boosting server performance for YiiMP  <= $COL_RESET"
# Boost Network Performance by Enabling TCP BBR
sudo apt install -y --install-recommends linux-generic-hwe-16.04
echo 'net.core.default_qdisc=fq' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_congestion_control=bbr' | sudo tee -a /etc/sysctl.conf

# Tune Network Stack
echo 'net.core.wmem_max=12582912' | sudo tee -a /etc/sysctl.conf
echo 'net.core.rmem_max=12582912' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_rmem= 10240 87380 12582912' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_wmem= 10240 87380 12582912' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_window_scaling = 1' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_timestamps = 1' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_sack = 1' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_no_metrics_save = 1' | sudo tee -a /etc/sysctl.conf
echo 'net.core.netdev_max_backlog = 5000' | sudo tee -a /etc/sysctl.conf

cd $HOME/yiimp_install_script/yiimp_single
