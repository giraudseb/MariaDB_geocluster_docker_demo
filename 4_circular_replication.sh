#!/bin/bash
#
#
#

. ./.secret
# Retreive replication parameters
binfile=$(docker exec -it mariadb1 mariadb -uroot -p${password} -e "SHOW MASTER STATUS\G" | grep -i file | sed 's/.*File: //g' | sed 's/\r//g')
binfile2=$(docker exec -it mariadb4 mariadb -uroot -p${password} -e "SHOW MASTER STATUS\G" | grep -i file | sed 's/.*File: //g' | sed 's/\r//g')
binfile7=$(docker exec -it mariadb7 mariadb -uroot -p${password} -e "SHOW MASTER STATUS\G" | grep -i file | sed 's/.*File: //g' | sed 's/\r//g')
binfile8=$(docker exec -it mariadb8 mariadb -uroot -p${password} -e "SHOW MASTER STATUS\G" | grep -i file | sed 's/.*File: //g' | sed 's/\r//g')

# Retreive IP address 
ip1=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$v.IPAddress}}{{end}}' mariadb1)
ip2=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$v.IPAddress}}{{end}}' mariadb2)
ip3=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$v.IPAddress}}{{end}}' mariadb3)
ip4=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$v.IPAddress}}{{end}}' mariadb4)
ip5=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$v.IPAddress}}{{end}}' mariadb5)
ip6=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$v.IPAddress}}{{end}}' mariadb6)
ip7=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$v.IPAddress}}{{end}}' mariadb7)
ip8=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$v.IPAddress}}{{end}}' mariadb8)
ipmax=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$v.IPAddress}}{{end}}' maxscale1)
ipmax2=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$v.IPAddress}}{{end}}' maxscale2)

user="seb"

echo "Creating DB3 & DB4 databases on DC1" 
docker exec -it mariadb1 mariadb -uroot -p${password} -e "CREATE DATABASE DB3;" || exit 8;
docker exec -it mariadb1 mariadb -uroot -p${password} -e "CREATE DATABASE DB4;" || exit 8;

echo "Creating DB3 databases on DC3" 
docker exec -it mariadb7 mariadb -uroot -p${password} -e "CREATE DATABASE DB3;" || exit 8;
echo "Creating DB4 databases on DC4" 
docker exec -it mariadb8 mariadb -uroot -p${password} -e "CREATE DATABASE DB4;" || exit 8;


echo "Setting up replication from DC1 to DC2 for all databases" 
docker exec -it mariadb4 mariadb -uroot -p${password} -e "stop slave;"|| exit 9; 
docker exec -it mariadb4 mariadb -uroot -p${password} -e "CHANGE MASTER 'db2' TO MASTER_USE_GTID =  slave_pos;"|| exit 9; 
docker exec -it mariadb4 mariadb -uroot -p${password} -e "CHANGE MASTER 'db2' TO MASTER_HOST='$ipmax',MASTER_USER='$user',MASTER_PASSWORD='$password',MASTER_PORT=4000,MASTER_LOG_FILE='$binfile',MASTER_SSL=0;"|| exit 9;  
docker exec -it mariadb4 mariadb -uroot -p${password} -e "CHANGE MASTER 'db2' TO MASTER_USE_GTID =  slave_pos;"|| exit 9; 
docker exec -it mariadb4 mariadb -uroot -p${password} -e "start slave db2;"|| exit 9;

echo "Setting up replication from DC2 to DC1 for all databases" 
docker exec -it mariadb1 mariadb -uroot -p${password} -e "stop slave;"|| exit 9; 
docker exec -it mariadb1 mariadb -uroot -p${password} -e "CHANGE MASTER 'db1' TO MASTER_USE_GTID =  slave_pos;"|| exit 9; 
docker exec -it mariadb1 mariadb -uroot -p${password} -e "CHANGE MASTER 'db1' TO MASTER_HOST='$ipmax2',MASTER_USER='seb',MASTER_PASSWORD='$password',MASTER_PORT=4000,MASTER_LOG_FILE='$binfile2',MASTER_SSL=0;"|| exit 9;  
docker exec -it mariadb1 mariadb -uroot -p${password} -e "CHANGE MASTER 'db1' TO MASTER_USE_GTID =  slave_pos;"|| exit 9; 
docker exec -it mariadb1 mariadb -uroot -p${password} -e "start slave db1;"|| exit 9;

echo "Setting up replication from DC1 to DC3 for DB3 databases" 
docker exec -it mariadb7 mariadb -uroot -p${password} -e "stop slave;"|| exit 9; 
docker exec -it mariadb7 mariadb -uroot -p${password} -e "CHANGE MASTER 'db3' TO MASTER_USE_GTID =  slave_pos;"|| exit 9; 
docker exec -it mariadb7 mariadb -uroot -p${password} -e "CHANGE MASTER 'db3' TO MASTER_HOST='$ipmax',MASTER_USER='$user',MASTER_PASSWORD='$password',MASTER_PORT=4000,MASTER_LOG_FILE='$binfile',MASTER_SSL=0;"|| exit 9;  
docker exec -it mariadb7 mariadb -uroot -p${password} -e "CHANGE MASTER 'db3' TO MASTER_USE_GTID =  slave_pos;"|| exit 9; 
docker exec -it mariadb7 mariadb -uroot -p${password} -e "start slave db3;"|| exit 9;

echo "Setting up replication from DC1 to DC4 for DB4 databases" 
docker exec -it mariadb8 mariadb -uroot -p${password} -e "stop slave;"|| exit 9; 
docker exec -it mariadb8 mariadb -uroot -p${password} -e "CHANGE MASTER 'db4 TO MASTER_USE_GTID =  slave_pos;"|| exit 9; 
docker exec -it mariadb8 mariadb -uroot -p${password} -e "CHANGE MASTER 'db4 TO MASTER_HOST='$ipmax2',MASTER_USER='seb',MASTER_PASSWORD='$password',MASTER_PORT=4000,MASTER_LOG_FILE='$binfile2',MASTER_SSL=0;"|| exit 9;  
docker exec -it mariadb8 mariadb -uroot -p${password} -e "CHANGE MASTER 'db4 TO MASTER_USE_GTID =  slave_pos;"|| exit 9; 
docker exec -it mariadb8 mariadb -uroot -p${password} -e "start slave db4;"|| exit 9;

# Create test databases
docker exec -it mariadb1 mariadb -uroot -p${password} -e "CREATE DATABASE 'trading';"|| exit 9; 
docker exec -it mariadb1 mariadb -uroot -p${password} -e "CREATE DATABASE 'CLIENTS';"|| exit 9; 
#docker exec -it mariadb7 mariadb -uroot -p${password} -e "CREATE DATABASE 'node7';"|| exit 9; 
#docker exec -it mariadb8 mariadb -uroot -p${password} -e "CREATE DATABASE 'node8';"|| exit 9; 
