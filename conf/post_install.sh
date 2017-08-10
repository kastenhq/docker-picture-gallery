#!/usr/bin/env bash

if [ ! -e /var/www/lychee/uploads/import ]
then
  ln -s /var/www/lychee /var/www/lychee/picture-gallery
  chown -R www-data:www-data /var/www/lychee
  mv -n /var/www/lychee/uploads_init/* /var/www/lychee/uploads/
  ls -l /var/www/lychee/uploads/
fi

if [ ! -e /data/config.php ]
then

  sleep 10

  for i in {1..12}
  do
    wget https://deis.com/images/blog-images/kubernetes-illustrated-guide-illustration-$i.png -O /uploads/import/Phippy_$i.png
  done

  cat > /data/config.php_tmp <<'LYCEECNFG'
<?php

###
# @name                 Configuration
# @author               Tobias Reich
# @copyright    2014 Tobias Reich
###

if(!defined('LYCHEE')) exit('Error: Direct access is not allowed!');

# Database configuration
$dbHost = 'localhost'; # Host of the database
$dbUser = '$DATABASE_USER'; # Username of the database
$dbPassword = '$DATABASE_SECRET'; # Password of the database
$dbName = '$DATABASE_NAME'; # Database name
$dbTablePrefix = ''; # Table prefix

?>
LYCEECNFG

  envsubst '${DATABASE_USER}:${DATABASE_SECRET}:${DATABASE_NAME}'< /data/config.php_tmp > /data/config.php

  chown -R www-data:www-data /data/config.php

  curl http://127.0.0.1/php/index.php --data 'function=Session%3A%3Alogin&user=testdrive_user&password=test_password'


  mysql -uroot -e 'update pics.lychee_settings set lychee_settings.value="$2a$10$IxyxLyzK0Txx8jEh/RpCVeWeVH5jlXpXbFO8kD053qtc/YptSVvcW" where lychee_settings.key="username"'
  mysql -uroot -e 'update pics.lychee_settings set lychee_settings.value="$2a$10$PlRAMDMPXSBaEl1wv6BCHeBjaQK42wvOpPrpF3dVC3M1jkcGtb2V2" where lychee_settings.key="password"'

  curl http://127.0.0.1/php/index.php -c cookies.txt --data 'function=Session%3A%3Ainit'
  curl http://127.0.0.1/php/index.php -b cookies.txt -c cookies.txt --data 'function=Session%3A%3Alogin&user=testdrive_user&password=test_password'
  curl http://127.0.0.1/php/index.php -b cookies.txt --data 'function=Import%3A%3Aserver&albumID=0&path=%2Fvar%2Fwww%2Flychee%2Fuploads%2Fimport%2F'
fi