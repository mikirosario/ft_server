CREATE DATABASE wordpress;
GRANT ALL PRIVILEGES ON wordpress.* TO 'root'@'localhost';
UPDATE mysql.user SET plugin = 'mysql_native_password' where user='root';
FLUSH PRIVILEGES;
