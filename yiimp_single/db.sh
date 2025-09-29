#!/usr/bin/env bash

#####################################################
# Created by klaxis for Yiimpool use...
#####################################################

source /etc/functions.sh
source /etc/yiimpoolversion.conf
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
if [[ ("$wireguard" == "true") ]]; then
  source $STORAGE_ROOT/yiimp/.wireguard.conf
fi

# Define MariaDB version
MARIADB_VERSION='10.3'

echo -e "$MAGENTA    <----------------------------->$COL_RESET"
echo -e "$MAGENTA     <--$YELLOW Installing MariaDB$MAGENTA $MARIADB_VERSION -->$COL_RESET"
echo -e "$MAGENTA    <----------------------------->$COL_RESET"
echo
# Set MariaDB root password for installation
sudo debconf-set-selections <<<"maria-db-$MARIADB_VERSION mysql-server/root_password password $DBRootPassword"
sudo debconf-set-selections <<<"maria-db-$MARIADB_VERSION mysql-server/root_password_again password $DBRootPassword"

# Install MariaDB
sudo apt install -y mariadb-server mariadb-client

# Display completion message
echo -e "$GREEN => MariaDB build complete <= $COL_RESET"
echo

# Display message for creating DB users
echo -e "$MAGENTA => Creating DB users for YiiMP <= $COL_RESET"
echo
# Check if wireguard variable is set to false
if [ "$wireguard" = "false" ]; then
  # Define SQL statements
  Q1="CREATE DATABASE IF NOT EXISTS ${YiiMPDBName};"
  Q2="GRANT ALL ON ${YiiMPDBName}.* TO '${YiiMPPanelName}'@'localhost' IDENTIFIED BY '$PanelUserDBPassword';"
  Q3="GRANT ALL ON ${YiiMPDBName}.* TO '${StratumDBUser}'@'localhost' IDENTIFIED BY '$StratumUserDBPassword';"
  Q4="FLUSH PRIVILEGES;"
  SQL="${Q1}${Q2}${Q3}${Q4}"
  # Run SQL statements
  sudo mysql -u root -p"${DBRootPassword}" -e "$SQL"

else
  # Define SQL statements
  Q1="CREATE DATABASE IF NOT EXISTS ${YiiMPDBName};"
  Q2="GRANT ALL ON ${YiiMPDBName}.* TO '${YiiMPPanelName}'@'${DBInternalIP}' IDENTIFIED BY '$PanelUserDBPassword';"
  Q3="GRANT ALL ON ${YiiMPDBName}.* TO '${StratumDBUser}'@'${DBInternalIP}' IDENTIFIED BY '$StratumUserDBPassword';"
  Q4="FLUSH PRIVILEGES;"
  SQL="${Q1}${Q2}${Q3}${Q4}"
  # Run SQL statements
  sudo mysql -u root -p"${DBRootPassword}" -e "$SQL"
fi

echo
echo -e "$MAGENTA => Creating my.cnf <= $COL_RESET"

if [[ ("$wireguard" == "false") ]]; then
  echo '[clienthost1]
user='"${YiiMPPanelName}"'
password='"${PanelUserDBPassword}"'
database='"${YiiMPDBName}"'
host=localhost
[clienthost2]
user='"${StratumDBUser}"'
password='"${StratumUserDBPassword}"'
database='"${YiiMPDBName}"'
host=localhost
[mysql]
user=root
password='"${DBRootPassword}"'
' | sudo -E tee $STORAGE_ROOT/yiimp/.my.cnf >/dev/null 2>&1

else
  echo '[clienthost1]
user='"${YiiMPPanelName}"'
password='"${PanelUserDBPassword}"'
database='"${YiiMPDBName}"'
host='"${DBInternalIP}"'
[clienthost2]
user='"${StratumDBUser}"'
password='"${StratumUserDBPassword}"'
database='"${YiiMPDBName}"'
host='"${DBInternalIP}"'
[mysql]
user=root
password='"${DBRootPassword}"'
' | sudo -E tee $STORAGE_ROOT/yiimp/.my.cnf >/dev/null 2>&1
fi

sudo chmod 0600 $STORAGE_ROOT/yiimp/.my.cnf

echo
echo -e "$YELLOW => Importing YiiMP Default database values <= $COL_RESET"
cd $STORAGE_ROOT/yiimp/yiimp_setup/yiimp/sql

# import SQL dump
sudo zcat 2024-03-06-complete_export.sql.gz  | sudo mysql -u root -p"${DBRootPassword}" "${YiiMPDBName}"

SQL_FILES=(
2024-04-01-shares_blocknumber.sql
2024-05-04-add_neoscrypt_xaya_algo.sql
2024-03-18-add_aurum_algo.sql
2024-04-05-algos_port_color.sql
2025-02-06-add_usemweb.sql
2024-03-29-add_github_version.sql
2024-04-22-add_equihash_algos.sql
2025-02-13-add_xelisv2-pepew.sql
2024-03-31-add_payout_threshold.sql
2024-04-23-add_pers_string.sql
2025-02-23-add_algo_kawpow.sql
2024-04-01-add_auto_exchange.sql
2024-04-29-add_sellthreshold.sql
2025-03-31-rename_table_exchange.sql
)

for file in "${SQL_FILES[@]}"; do
  sudo mysql -u root -p"${DBRootPassword}" "${YiiMPDBName}" --force < "$file"
done

echo
echo -e "$YELLOW <-- Datebase import $GREEN complete -->$COL_RESET"

echo
echo -e "$YELLOW => Tweaking MariaDB for better performance <= $COL_RESET"

# Define MariaDB configuration changes
config_changes=(
  'max_connections = 800'
  'thread_cache_size = 512'
  'tmp_table_size = 128M'
  'max_heap_table_size = 128M'
  'wait_timeout = 60'
  'max_allowed_packet = 64M'
)

# Add bind-address if wireguard is true.
if [[ "$wireguard" == "true" ]]; then
  config_changes+=("bind-address=$DBInternalIP")
fi

# Prepare the configuration changes as a string with each option on a separate line
config_string=$(printf "%s\n" "${config_changes[@]}")

# Apply changes to MariaDB configuration
sudo bash -c "echo \"$config_string\" >> /etc/mysql/my.cnf"

# Restart MariaDB
restart_service mysql

# Installing PhpMyAdmin
echo
echo
echo -e "$CYAN => Installing phpMyAdmin $COL_RESET"
echo
sleep 3

if [[ ("$InstallphpMyAdmin" == "y" || "$InstallphpMyAdmin" == "Y" || "$InstallphpMyAdmin" == "yes" || "$InstallphpMyAdmin" == "Yes" || "$InstallphpMyAdmin" == "YES") ]]; then

echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-user string root" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $DBRootPassword" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $PanelUserDBPassword" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $PanelUserDBPassword" | sudo debconf-set-selections
sudo apt -y install phpmyadmin
echo -e "$GREEN Done...$COL_RESET"
fi


set +eu +o pipefail
cd $HOME/yiimp_installation/yiimp_single