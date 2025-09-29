sudo mkdir -p /home/crypto-data/yiimp/site/web/yaamp/runtime
sudo mkdir -p /home/crypto-data/yiimp/site/web/assets
grep -E '^(user|group)\s*=' /etc/php/7.4/fpm/pool.d/www.conf
# usually: user = www-data / group = www-data
sudo chown -R www-data:www-data /home/crypto-data/yiimp/site/web/yaamp/runtime /home/crypto-data/yiimp/site/web/assets
sudo find /home/crypto-data/yiimp/site/web/yaamp/runtime -type d -exec chmod 775 {} \;
sudo find /home/crypto-data/yiimp/site/web/yaamp/runtime -type f -exec chmod 664 {} \;
sudo find /home/crypto-data/yiimp/site/web/assets          -type d -exec chmod 775 {} \;
sudo find /home/crypto-data/yiimp/site/web/assets          -type f -exec chmod 664 {} \;

# keep group write on newly created items
sudo chmod g+s /home/crypto-data/yiimp/site/web/yaamp/runtime /home/crypto-data/yiimp/site/web/assets
sudo systemctl reload php7.4-fpm
sudo rm -rf /home/crypto-data/yiimp/site/web/assets/* 2>/dev/null
sudo systemctl reload php7.4-fpm
sudo systemctl reload nginx
