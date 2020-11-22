# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    setup.sh                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: user42 <user42@student.42.fr>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/10/20 12:24:11 by user42            #+#    #+#              #
#    Updated: 2020/11/22 17:08:27 by user42           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

#!/bin/bash
### COLORS
Red="\e[31m"
Green="\e[32m"
Dark_yellow="\n\e[33;1m"
Yellow="\e[33m"
Blue="\e[94m"
Default="\e[0m"
### SERVICES
services="ftps mysql phpmyadmin nginx wordpress influxdb telegraf grafana"

printf "${Dark_yellow}   __ _                         _               \n";
printf "  / _| |                       (_)              \n";
printf " | |_| |_   ___  ___ _ ____   ___  ___ ___  ___ \n";
printf " |  _| __| / __|/ _ \ '__\ \ / / |/ __/ _ \/ __|\n";
printf " | | | |_  \__ \  __/ |   \ V /| | (_|  __/\__ \\ \n";
printf " |_|  \__| |___/\___|_|    \_/ |_|\___\___||___/\n";
printf "       ______                                   \n";
printf "      |______|                                  \n";
printf "\n";
printf "\n${Blue}";

printf "\n\n${Yellow} --- Cleaning former shinanegans... ---${Default}\n";
service nginx stop
sudo pkill mysql 
sudo apt-get update -y
sudo apt-get -y dist-upgrade
sudo apt-get autoremove -y
sudo apt-get install docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo chown user42:user42 /var/run/docker.sock
sudo rm -rf /usr/local/bin/kubectl
minikube delete 
rm -rf ~/.minikube
sudo rm -rf /usr/local/bin/minikube

printf "\n\n${Yellow} --- Testing if docker works... ---${Default}\n";
sleep 1
docker ps > /dev/null;

if [[ $? == 1 ]];
then
	printf "${Red} --- ERROR! It seems that docker doesn't work properly.
	This may be the case if you're using 42's VM.
	We will attempt to fix it. In order for it to start working, you\n
	will have to log out and login again. Sorry! ---${Default}\n";
	sleep 1
	sudo usermod -aG docker $USER;
	printf "${Green}\n --- Nice! We've applied the fix. Now please log out and log in again. ---${Default}\n";
	exit 1;
else
	printf "${Green}\n --- Noice! Docker works fine.  ---${Default}\n";
fi

printf "\n\n${Yellow} --- Installing Kubernet... ---${Default}\n";
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

printf "${Yellow}\n --- Installing latest version of Minikube... ---${Default}\n";
sleep 1
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube && sudo install minikube /usr/local/bin/ && rm minikube

printf "${Yellow}\n --- Starting Minikube (Be patient)... ---${Default}\n";
sleep 1
minikube start --driver=docker
printf "${Yellow}\n --- Checking Minikube version... ---${Default}\n";
minikube update-check
CLUSTER_IP=$(minikube ip)
printf "${Green}Your cluster IP address is: $CLUSTER_IP ${Default}\n"

printf "${Yellow}\n --- Enabling MetalLB ---${Default}\n";
minikube addons enable metallb

printf "${Yellow}\n --- Configuring MetalLB from config_map.yml file... ---${Default}\n";
sed -i.bak "s/CLUSTER_IP/"$CLUSTER_IP"/g" srcs/config_map.yml 
kubectl apply -f srcs/config_map.yml
if (cat srcs/config_map.yml.bak > /dev/null) then
rm srcs/config_map.yml && mv srcs/config_map.yml.bak srcs/config_map.yml ;
fi 
printf "${Green}\nMetalLB Configuration:${Default}\n";
kubectl describe configmap config -n metallb-system
sleep 1

sed -i.bak "s/CLUSTER_IP/"$CLUSTER_IP"/g" srcs/mysql/wordpress.sql

eval $(minikube docker-env)
docker system prune -f

printf "${Yellow}\n --- Installing the services... ---${Default}\n";
for service in $services
do
	printf "${Red}\n\n${service}:${Default}\n\n";
	docker exec -it minikube docker rmi -f $service > /dev/null
	kubectl delete -f ./srcs/$service/$service.yml > /dev/null
	while (kubectl get pods | grep $service > /dev/null) do
		sleep 2;
	done
	docker build -t $service ./srcs/$service/.
	printf "${Green}\nImage $service built!${Default}\n\n";
	kubectl apply -f ./srcs/$service/$service.yml
	printf "${Green}\nService $service set!${Default}\n\n";
done

if (cat srcs/mysql/wordpress.sql.bak > /dev/null) then
rm srcs/mysql/wordpress.sql && mv srcs/mysql/wordpress.sql.bak srcs/mysql/wordpress.sql ;
fi 

printf "${Blue}\n All the required services were set!\n░░░░░░░░░░░░▄▄░░░░░░░░░░░░░░\n░░░░░░░░░░░█░░█░░░░░░░░░░░░░\n░░░░░░░░░░░█░░█░░░░░░░░░░░░░\n░░░░░░░░░░█░░░█░░░░░░░░░░░░░\n░░░░░░░░░█░░░░█░░░░░░░░░░░░░\n██████▄▄█░░░░░██████▄░░░░░░░\n▓▓▓▓▓▓█░░░░░░░░░░░░░░█░░░░░░\n▓▓▓▓▓▓█░░░░░░░░░░░░░░█░░░░░░\n▓▓▓▓▓▓█░░░░░░░░░░░░░░█░░░░░░\n▓▓▓▓▓▓█░░░░░░░░░░░░░░█░░░░░░\n▓▓▓▓▓▓█░░░░░░░░░░░░░░█░░░░░░\n▓▓▓▓▓▓█████░░░░░░░░░██░░░░░░\n█████▀░░░░▀▀████████░░░░░░░░\n░░░░░░░░░░░░░░░░░░░░░░░░░░░░\n\n Let's see if everything is working fine...${Default}\n"

sleep 2
printf "${Yellow}\n --- Launching minikube dashboard... ---${Default}\n";
printf "${Red}Don't close this terminal!${Default}\n";
minikube dashboard