#!/bin/bash
#
# Init Docker authentication 
# 
# seb@mariadb.com
#

. ./.secret

#kubectl create secret docker-registry mariadb-enterprise \
#   --docker-server=docker.mariadb.com \
#   --docker-username=${email}@mariadb.com \
#   --docker-password=${token}
echo "Login to mariadb docker repo using registered MariaDB email address and token as password";
echo "Using : docker login docker.mariadb.com ";
docker login docker.mariadb.com 
