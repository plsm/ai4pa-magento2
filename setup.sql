CREATE DATABASE magento_db;
CREATE USER 'magento_user'@'localhost' IDENTIFIED BY 'Password';
GRANT ALL ON magento_db.* TO 'magento_user'@'localhost';
FLUSH PRIVILEGES;
