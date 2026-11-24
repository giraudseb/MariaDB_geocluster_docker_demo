# MariaDB_docker_demo
seb@mariadb.com

Automated MariaDB Enterprise demo platform on top of docker

This solution build a very simple but complete fully autromated MariaDB Enterprise asynchronous GEO cluster on top docker

It was developped and fully tested on Macbook

This project is designed to make a very fast demo platform on several kind of operating system (Posix compliant mainly)
This project was designed to run with the MariaDB monitor Swift application available at   https://github.com/giraudseb/MariaDB_Monitor_EN
First of all complete the .secret file with your own authentication then you should be good to go and perform a demo in less than 30 seconds

Avoid any workload before the whole setup is complete, either way MaxScale will block the user according due to a lack of grant before the workload arrived

Copy and complete the .secret file using .secret.template completing with the accurate authentication parameters

# Strat the demo 
Start with ./demo.sh 

# Stop the Demo
Destroy the whole deployment with ./5_destroy.sh

Also, do ensure to delete all the created storage as it is not done automatically for now

# Geocluster with multi site branch 
Having 2 mains site DC1 & DC2 
DC 3 is a small site hosting CLIENTS and DB3 only 
DC 4 is also a small site hosting CLIENTS and DB4 only 

DC1 and DC2 will get the databases

#TODO add disk cleanup
#TODO add Exa (not already working on Macbook M architecture)
#TODO add the operator full demo
#TODO add Kubernetes Operator
#TODO add docker compose deployment base 
 
