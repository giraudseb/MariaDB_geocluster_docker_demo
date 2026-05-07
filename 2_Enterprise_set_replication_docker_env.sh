#!/bin/bash
#
#
#

. ./.secret

# Retreive IP address 
ip1=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$v.IPAddress}}{{end}}' mariadb1)
ip2=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$v.IPAddress}}{{end}}' mariadb2)
ip3=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$v.IPAddress}}{{end}}' mariadb3)
ip4=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$v.IPAddress}}{{end}}' mariadb4)
ip5=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$v.IPAddress}}{{end}}' mariadb5)
ip6=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$v.IPAddress}}{{end}}' mariadb6)

for server in mariadb1 mariadb2 mariadb3 mariadb4 mariadb5 mariadb6
do 
	docker exec -i ${server} mariadb -u root -p$password -e "
	CREATE USER IF NOT EXISTS 'maxscale_user'@'%' IDENTIFIED BY '${password}';
	GRANT SELECT ON mysql.user TO 'maxscale_user'@'%';
	GRANT SELECT ON mysql.db TO 'maxscale_user'@'%';
	GRANT SELECT ON mysql.tables_priv TO 'maxscale_user'@'%';
	GRANT SELECT ON mysql.columns_priv TO 'maxscale_user'@'%';
	GRANT SELECT ON mysql.proxies_priv TO 'maxscale_user'@'%';
	GRANT SELECT ON mysql.roles_mapping TO 'maxscale_user'@'%';
	GRANT SHOW DATABASES ON *.* TO 'maxscale_user'@'%';
	GRANT REPLICATION CLIENT ON *.* TO 'maxscale_user'@'%';
	FLUSH PRIVILEGES;
	"
done 

# Retreive replication parameters 
binfile=$(docker exec -it mariadb1 mariadb -uroot -p${password} -e "SHOW MASTER STATUS\G" | grep -i file | sed 's/.*File: //g' | sed 's/\r//g')
binfile2=$(docker exec -it mariadb4 mariadb -uroot -p${password} -e "SHOW MASTER STATUS\G" | grep -i file | sed 's/.*File: //g' | sed 's/\r//g')

# Create a first querie 
docker exec -it mariadb1 mariadb -uroot -p${password} -e "CREATE DATABASE SEB;" || exit 8;
docker exec -it mariadb1 mariadb -uroot -p${password} -e "CREATE TABLE SEB.test(id int,description varchar(256));" || exit 8;
docker exec -it mariadb1 mariadb -uroot -p${password} -e "INSERT INTO SEB.test(id, description) VALUES (1,'test by seb');" || exit 8;

# Add grants for MariaDB Monitor application  
docker exec -it mariadb1 mariadb -uroot -p${password} -e "GRANT ALL PRIVILEGES ON *.* TO 'seb'@'127.0.0.1' IDENTIFIED BY '${password}';" || exit 8;
docker exec -it mariadb1 mariadb -uroot -p${password} -e "GRANT ALL PRIVILEGES ON *.* TO 'seb'@'%' IDENTIFIED BY '${password}';" || exit 8;
docker exec -it mariadb1 mariadb -uroot -p${password} -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${password}';" || exit 8;
docker exec -it mariadb1 mariadb -uroot -p${password} -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'127.0.0.1' IDENTIFIED BY '${password}';" || exit 8;
docker exec -it mariadb1 mariadb -uroot -p${password} -e "FLUSH PRIVILEGES;" || exit 8;

# Create a first querie 
docker exec -it mariadb4 mariadb -uroot -p${password} -e "CREATE DATABASE SEB;" || exit 8;
docker exec -it mariadb4 mariadb -uroot -p${password} -e "CREATE TABLE SEB.test(id int,description varchar(256));" || exit 8;
docker exec -it mariadb4 mariadb -uroot -p${password} -e "INSERT INTO SEB.test(id, description) VALUES (1,'test by seb');" || exit 8;

# Add grants for MariaDB Monitor application  
docker exec -it mariadb4 mariadb -uroot -p${password} -e "GRANT ALL PRIVILEGES ON *.* TO 'seb'@'127.0.0.1' IDENTIFIED BY '${password}';" || exit 8;
docker exec -it mariadb4 mariadb -uroot -p${password} -e "GRANT ALL PRIVILEGES ON *.* TO 'seb'@'%' IDENTIFIED BY '${password}';" || exit 8;
docker exec -it mariadb4 mariadb -uroot -p${password} -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${password}';" || exit 8;
docker exec -it mariadb4 mariadb -uroot -p${password} -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'127.0.0.1' IDENTIFIED BY '${password}';" || exit 8;
docker exec -it mariadb4 mariadb -uroot -p${password} -e "FLUSH PRIVILEGES;" || exit 8;

echo "Pause during 10 sec"
sleep 10 

# Start replication 
echo Node2
docker exec -it mariadb2 mariadb -uroot -p${password} -e "stop slave;"|| exit 9; 
docker exec -it mariadb2 mariadb -uroot -p${password} -e "CHANGE MASTER TO MASTER_HOST='$ip1',MASTER_USER='$user',MASTER_PASSWORD='$password',MASTER_PORT=3306,MASTER_LOG_FILE='$binfile';"|| exit 9; 
docker exec -it mariadb2 mariadb -uroot -p${password} -e "CHANGE MASTER TO MASTER_USE_GTID =  slave_pos;"|| exit 9; 
docker exec -it mariadb2 mariadb -uroot -p${password} -e "start slave;"|| exit 9; 
# on Node3 now
echo Node3
docker exec -it mariadb3 mariadb -uroot -p${password} -e "stop slave;"|| exit 9; 
docker exec -it mariadb3 mariadb -uroot -p${password} -e "CHANGE MASTER TO MASTER_HOST='$ip1',MASTER_USER='$user',MASTER_PASSWORD='$password',MASTER_PORT=3306,MASTER_LOG_FILE='$binfile';"|| exit 9; 
docker exec -it mariadb3 mariadb -uroot -p${password} -e "CHANGE MASTER TO MASTER_USE_GTID =  slave_pos;"|| exit 9; 
docker exec -it mariadb3 mariadb -uroot -p${password} -e "start slave;"|| exit 9; 


# Start replication 
echo Node5
docker exec -it mariadb5 mariadb -uroot -p${password} -e "stop slave;"|| exit 9; 
docker exec -it mariadb5 mariadb -uroot -p${password} -e "CHANGE MASTER TO MASTER_HOST='$ip4',MASTER_USER='$user',MASTER_PASSWORD='$password',MASTER_PORT=3306,MASTER_LOG_FILE='$binfile2';"|| exit 9; 
docker exec -it mariadb5 mariadb -uroot -p${password} -e "CHANGE MASTER TO MASTER_USE_GTID =  slave_pos;"|| exit 9; 
docker exec -it mariadb5 mariadb -uroot -p${password} -e "start slave;"|| exit 9; 
# on Node6 now
echo Node6
docker exec -it mariadb6 mariadb -uroot -p${password} -e "stop slave;"|| exit 9; 
docker exec -it mariadb6 mariadb -uroot -p${password} -e "CHANGE MASTER TO MASTER_HOST='$ip4',MASTER_USER='$user',MASTER_PASSWORD='$password',MASTER_PORT=3306,MASTER_LOG_FILE='$binfile2';"|| exit 9; 
docker exec -it mariadb6 mariadb -uroot -p${password} -e "CHANGE MASTER TO MASTER_USE_GTID =  slave_pos;"|| exit 9; 
docker exec -it mariadb6 mariadb -uroot -p${password} -e "start slave;"|| exit 9;

