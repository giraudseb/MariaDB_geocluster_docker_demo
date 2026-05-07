#!/bin/bash
#
# Seb on 2026-04-23
# Create 3 MariaDB Enterprise docker instances
#
# mariadb1 listenning on 127.0.0.1:3307
# mariadb2 listenning on 127.0.0.1:3308
# mariadb3 listenning on 127.0.0.1:3309 
#
. .secret

# Environment checks
which docker || curl -sSL https://get.docker.com/ | sh || { echo "Docker not installed"; exit 1;}
docker pull docker.mariadb.com/enterprise-server:latest || { echo "Docker not started";  exit 2;}
docker images || { echo "Image docker non récupéré"; exit 3;}
docker ps || { echo "Docker non démarré"; exit 4;}

# Creating PODs
docker run --name mariadb1 -e MYSQL_ROOT_PASSWORD=${password} -p 3307:3306 -d -v $(pwd)/server1.cnf:/etc/mysql/conf.d/seb.cnf docker.mariadb.com/enterprise-server:latest || exit 5; 
docker run --name mariadb2 -e MYSQL_ROOT_PASSWORD=${password} -p 3308:3306 -d -v $(pwd)/server2.cnf:/etc/mysql/conf.d/seb.cnf docker.mariadb.com/enterprise-server:latest || exit 6; 
docker run --name mariadb3 -e MYSQL_ROOT_PASSWORD=${password} -p 3309:3306 -d -v $(pwd)/server3.cnf:/etc/mysql/conf.d/seb.cnf docker.mariadb.com/enterprise-server:latest || exit 7; 
docker run --name mariadb4 -e MYSQL_ROOT_PASSWORD=${password} -p 3310:3306 -d -v $(pwd)/server4.cnf:/etc/mysql/conf.d/seb.cnf docker.mariadb.com/enterprise-server:latest || exit 5; 
docker run --name mariadb5 -e MYSQL_ROOT_PASSWORD=${password} -p 3311:3306 -d -v $(pwd)/server5.cnf:/etc/mysql/conf.d/seb.cnf docker.mariadb.com/enterprise-server:latest || exit 6; 
docker run --name mariadb6 -e MYSQL_ROOT_PASSWORD=${password} -p 3312:3306 -d -v $(pwd)/server6.cnf:/etc/mysql/conf.d/seb.cnf docker.mariadb.com/enterprise-server:latest || exit 7; 
