#!/bin/bash
#
#
#

. .secret

servers=$(docker inspect -f '{{.Name}} - {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps -q)|grep -i mariadb)

# 1. On définit nos variables (vous pouvez même les récupérer via une autre commande)
IP_MAXSCALE_PRI=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$v.IPAddress}}{{end}}' maxscale_primary)
IP_NODE_1=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$v.IPAddress}}{{end}}' mariadb1)
IP_NODE_2=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$v.IPAddress}}{{end}}' mariadb2)
IP_NODE_3=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$v.IPAddress}}{{end}}' mariadb3)
IP_NODE_4=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$v.IPAddress}}{{end}}' mariadb4)
IP_NODE_5=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$v.IPAddress}}{{end}}' mariadb5)
IP_NODE_6=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$v.IPAddress}}{{end}}' mariadb6)

echo "Génération du fichier maxscale.cnf avec les IPs : $IP_NODE_1, $IP_NODE_2, $IP_NODE_3..."

# 2. On génère le fichier à la volée grâce à la commande "cat"
cat <<EOF > maxscale_sec.cnf
[maxscale]
threads=auto
admin_host=0.0.0.0
admin_port=8989
admin_gui=true
admin_secure_gui=false


#[maxscale_pri]
#type=server
#address=$IP_MAXSCALE_PRI
#port=4000
#protocol=MariaDBBackend
#initial_status=write

[server1]
type=server
address=$IP_NODE_1
port=3306
protocol=MariaDBBackend

[server2]
type=server
address=$IP_NODE_2
port=3306
protocol=MariaDBBackend

[server3]
type=server
address=$IP_NODE_3
port=3306
protocol=MariaDBBackend

[server4]
type=server
address=$IP_NODE_4
port=3306
protocol=MariaDBBackend

[server5]
type=server
address=$IP_NODE_5
port=3306
protocol=MariaDBBackend

[server6]
type=server
address=$IP_NODE_6
port=3306
protocol=MariaDBBackend

[DC-principal-monitor]
type=monitor
module=mariadbmon
servers=server1,server2,server3,server4,server5,server6
user=${user}
password=${password}
monitor_interval=200ms
auto_failover=true
auto_rejoin=true
backend_timeout=1s
backend_read_timeout=1s
cooperative_monitoring_locks=majority_of_all
servers_no_promotion=server4,server5,server6

[DC-principal-RWS]
type=service
router=readwritesplit
#cluster=DC-principal-monitor
servers=server1,server2,server3, server4, server5,server6
user=${user}
password=${password}
transaction_replay                   = true
transaction_replay_max_size          = 100Mi
transaction_replay_attempts          = 100
transaction_replay_retry_on_deadlock = true
enable_root_user                     = true
master_reconnection                  = true
master_failure_mode                  = fail_on_write
slave_selection_criteria             = ADAPTIVE_ROUTING  
#That'll prefer local nodes for reads ; #It measures against execution time average as well as network ping so that should end with more reads locally 
max_replication_lag                  = 5s

[DC-principal-port]
type=listener
service=DC-principal-RWS
protocol=MariaDBClient
port=4000


#[DC-secondaire-monitor]
#type=monitor
#module=mariadbmon
##servers=maxscale_pri,server4,server5,server6
#servers=server4,server5,server6
#user=${user}
#password=${password}
#monitor_interval=200ms
##auto_failover=true
##auto_rejoin=true
#backend_timeout=1s
#backend_read_timeout=1s
#servers_no_promotion=server4,server5,server6
#
#[DC-secondaire-RWS]
#type=service
#router=readwritesplit
#servers=maxscale_pri,server4,server5,server6
#user=${user}
#password=${password}
#transaction_replay                   = true
#transaction_replay_max_size          = 100Mi
#transaction_replay_attempts          = 100
#transaction_replay_retry_on_deadlock = true
#enable_root_user		     = true
#master_reconnection		     = true     
#master_failure_mode		     = fail_on_write 
#max_replication_lag          = 5s
#
#
#[DC-secondaire-port]
#type=listener
#service=DC-secondaire-RWS
#protocol=MariaDBClient
#port=4001
EOF

echo "Fichier généré ! Démarrage du conteneur Docker MaxScale Secondary..."
## Authenticate, pull, and run in one sequence
echo "${token}" | docker login docker.mariadb.com -u ${mail} --password-stdin
docker pull docker.mariadb.com/maxscale:latest
#docker run -d -p 4000:4000 -p 4001:4001 -p 8989:8989 --name maxscale_primary -v $(pwd)/maxscale_pri.cnf:/etc/maxscale.cnf docker.mariadb.com/maxscale:latest
docker run -d -p 4002:4000 -p 4003:4001 -p 8990:8989 --name maxscale_secondary -v $(pwd)/maxscale_sec.cnf:/etc/maxscale.cnf docker.mariadb.com/maxscale:latest
 echo "Maxscale_secondary is listenning on 4002 (from 4000) and 4003 (from 4001)"         
