#!/bin/bash
#
#
#
. .secret

docker container stop mariadb1 mariadb2 mariadb3 mariadb4 mariadb5 mariadb6 maxscale1 
docker container rm mariadb1 mariadb2 mariadb3 mariadb4 mariadb5 mariadb6 maxscale1
