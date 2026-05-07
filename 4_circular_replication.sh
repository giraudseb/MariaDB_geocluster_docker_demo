#!/bin/bash
#
#
#

. ./.secret
# Retreive replication parameters
binfile=$(docker exec -it mariadb1 mariadb -uroot -p${password} -e "SHOW MASTER STATUS\G" | grep -i file | sed 's/.*File: //g' | sed 's/\r//g')
binfile2=$(docker exec -it mariadb4 mariadb -uroot -p${password} -e "SHOW MASTER STATUS\G" | grep -i file | sed 's/.*File: //g' | sed 's/\r//g')

# Retreive IP address 
ip1=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$v.IPAddress}}{{end}}' mariadb1)
ip2=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$v.IPAddress}}{{end}}' mariadb2)
ip3=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$v.IPAddress}}{{end}}' mariadb3)
ip4=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$v.IPAddress}}{{end}}' mariadb4)
ip5=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$v.IPAddress}}{{end}}' mariadb5)
ip6=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$v.IPAddress}}{{end}}' mariadb6)
ipmax=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$v.IPAddress}}{{end}}' maxscale1)

user="seb"

echo Circular replication
docker exec -it mariadb4 mariadb -uroot -p${password} -e "stop slave;"|| exit 9; 
docker exec -it mariadb4 mariadb -uroot -p${password} -e "CHANGE MASTER TO MASTER_USE_GTID =  slave_pos;"|| exit 9; 
docker exec -it mariadb4 mariadb -uroot -p${password} -e "CHANGE MASTER TO MASTER_HOST='$ipmax',MASTER_USER='$user',MASTER_PASSWORD='$password',MASTER_PORT=4000,MASTER_LOG_FILE='$binfile',MASTER_SSL=0;"|| exit 9;  
docker exec -it mariadb4 mariadb -uroot -p${password} -e "CHANGE MASTER TO MASTER_USE_GTID =  slave_pos;"|| exit 9; 
docker exec -it mariadb4 mariadb -uroot -p${password} -e "start slave;"|| exit 9;

docker exec -it mariadb1 mariadb -uroot -p${password} -e "stop slave;"|| exit 9; 
docker exec -it mariadb1 mariadb -uroot -p${password} -e "CHANGE MASTER TO MASTER_USE_GTID =  slave_pos;"|| exit 9; 
docker exec -it mariadb1 mariadb -uroot -p${password} -e "CHANGE MASTER TO MASTER_HOST='$ipmax',MASTER_USER='seb',MASTER_PASSWORD='$password',MASTER_PORT=4001,MASTER_LOG_FILE='$binfile2',MASTER_SSL=0;"|| exit 9;  
docker exec -it mariadb1 mariadb -uroot -p${password} -e "CHANGE MASTER TO MASTER_USE_GTID =  slave_pos;"|| exit 9; 
docker exec -it mariadb1 mariadb -uroot -p${password} -e "start slave;"|| exit 9;
