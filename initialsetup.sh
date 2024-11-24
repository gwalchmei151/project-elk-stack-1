#! /bin/bash

function check_root {
	if [ $EUID != 0 ]; then
		echo -e "Please run script as root user\n"
		exit 2	
	fi
	}

function update_repo {
    apt update > /dev/null
}

function install_nala {
    apt install nala
}

function install_packages {
    nala install sudo net-tools gnupg2 apt-transport-https curl vim zip
}

function main {
    check_root
    update_repo
    install_nala
    install_packages
    echo "Importing Elasticsearch Signing Key..."
    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
    echo "Done"
}

main