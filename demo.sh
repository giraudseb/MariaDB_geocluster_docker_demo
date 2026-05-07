#!/bin/bash

#0_docker-registry.sh

bash 1_Enterprise_create_replication_docker_env.sh &&\
sleep 10 &&\

bash 2_Enterprise_set_replication_docker_env.sh &&\
bash 3_maxscale.sh &&\
sleep 5 &&\
bash 4_circular_replication.sh &&\
echo "READY !"
echo "http://127.0.0.1:8989" 
echo "http://127.0.0.1:8990" 

#5_destroy.sh
