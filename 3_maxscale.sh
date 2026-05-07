#!/bin/bash
#
#
#

. .secret

servers=$(docker inspect -f '{{.Name}} - {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps -q)|grep -i mariadb)

# 1. On définit nos variables (vous pouvez même les récupérer via une autre commande)
IP_NODE_1=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$v.IPAddress}}{{end}}' mariadb1)
IP_NODE_2=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$v.IPAddress}}{{end}}' mariadb2)
IP_NODE_3=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$v.IPAddress}}{{end}}' mariadb3)
IP_NODE_4=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$v.IPAddress}}{{end}}' mariadb4)
IP_NODE_5=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$v.IPAddress}}{{end}}' mariadb5)
IP_NODE_6=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$v.IPAddress}}{{end}}' mariadb6)

echo "Génération du fichier maxscale.cnf avec les IPs : $IP_NODE_1, $IP_NODE_2, $IP_NODE_3..."

# 2. On génère le fichier à la volée grâce à la commande "cat"
cat <<EOF > maxscale.cnf
[maxscale]
threads=auto
admin_host=0.0.0.0
admin_port=8989
admin_gui=true
admin_secure_gui=false

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

[DC1-monitor]
type=monitor
module=mariadbmon
servers=server1,server2,server3
user=${user}
password=${password}
monitor_interval=200ms
auto_failover=true
auto_rejoin=true
backend_connect_timeout=1s
backend_read_timeout=1s


[DC1-RWS]
type=service
router=readwritesplit
servers=server1,server2,server3
user=${user}
password=${password}
transaction_replay                   = true
transaction_replay_max_size          = 100Mi
transaction_replay_attempts          = 100
transaction_replay_retry_on_deadlock = true
enable_root_user                     = true
master_reconnection                  = true
master_failure_mode                  = fail_on_write

[DC1-port]
type=listener
service=DC1-RWS
protocol=MariaDBClient
port=4000

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

[DC2-monitor]
type=monitor
module=mariadbmon
servers=server4,server5,server6
user=${user}
password=${password}
monitor_interval=200ms
auto_failover=true
auto_rejoin=true
backend_connect_timeout=1s
backend_read_timeout=1s

[DC2-RWS]
type=service
router=readwritesplit
servers=server4,server5,server6
user=${user}
password=${password}
transaction_replay                   = true
transaction_replay_max_size          = 100Mi
transaction_replay_attempts          = 100
transaction_replay_retry_on_deadlock = true
enable_root_user		     = true
master_reconnection		     = true     
master_failure_mode		     = fail_on_write 

[DC2-port]
type=listener
service=DC2-RWS
protocol=MariaDBClient
port=4001
EOF

echo "Fichier généré ! Démarrage du conteneur Docker..."
## Authenticate, pull, and run in one sequence
echo "${token}" | docker login docker.mariadb.com -u ${mail} --password-stdin
docker pull docker.mariadb.com/maxscale:latest
docker run -d -p 4000:4000 -p 4001:4001 -p 8989:8989 --name maxscale1 -v $(pwd)/maxscale.cnf:/etc/maxscale.cnf docker.mariadb.com/maxscale:latest

