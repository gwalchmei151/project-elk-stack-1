#! /bin/bash

# Terminal colour variables
Black='\033[0;30m'
Red='\033[0;31m'
Green='\033[0;32m'
Orange='\033[0;33m'
Blue='\033[0;34m'
Purple='\033[0;35m'
Cyan='\033[0;36m'
Light_Gray='\033[0;37m'
Dark_Gray='\033[1;30m'
Light_Red='\033[1;31m'
Light_Green='\033[1;32m'
Yellow='\033[1;33m'
Light_Blue='\033[1;34m'
Light_Purple='\033[1;35m'
Light_Cyan='\033[1;36m'
White='\033[1;37m'
NC='\033[0m' # No Color




function check_root {
	if [ $EUID != 0 ]; then
		echo -e "Please run script as root user\n"
		exit 2	
	fi
	}

function check_users {
    readarray -t HOMEDIR < <(ls /home)
    # echo -e "\nList of users on this host with a drive in /home: \n"
	# printf "\t|%10s|\n" "User"
    echo -e "\n${Orange}[ ! ]${NC} Select a user on this host to install as: \n"
    printf "\t| %3s | %10s |\n" "No." "User"
    printf "\t|-----|------------|\n"
    USERNAMES=()
    # i=0
	# for ELEMENT in "${HOMEDIR[@]}"; do
    #         #echo "$ELEMENT"
    #         i=$(( $i + 1 ))
	# 		USERNAMES+=($ELEMENT)
	# 		printf "\t|${Purple}%5s${NC}|${Light_Cyan}%10s${NC}|\n" "$COUNT" "$ELEMENT"
	# done
    i=0
    for ELEMENT in "${HOMEDIR[@]}"; do
        i=$((i + 1))
        printf "\t| ${Purple}%3s${NC} | ${Light_Cyan}%10s${NC} |\n" "$i" "$ELEMENT"
    done

    read -p "Enter Selection Number Here: " OPT
    OPT=$((OPT - 1)) 
    echo -e "${Light_Green}[ + ]${NC} You have chosen to install as ${Light_Cyan}${HOMEDIR[$OPT]}${NC}"
    echo -e "${Light_Green}[ + ] Changing directory to ${Light_Cyan}/home/${HOMEDIR[$OPT]}${NC}..."
    cd /home/"${HOMEDIR[$OPT]}"
}

function install_starship {
    echo -e "${Light_Green}[ + ]${NC} Installing starship prompt${NC}"
    curl -sS https://starship.rs/install.sh | sh
    echo -e "${Light_Green}[ + ]${NC} Starship Installed${NC}"
    mkdir ".config"
    cd ".config"
    wget "https://raw.githubusercontent.com/gwalchmei151/tushar-personal-configs/refs/heads/main/starship.toml"
    reset
}   

function update_repo {
    apt update > /dev/null
}

function install_nala {
    apt install nala
}

function install_packages {
    nala install sudo net-tools gnupg2 apt-transport-https curl vim
}

function choose_installer {
    PS3=$(echo -e "${Orange}[ ! ]${NC} Please choose which you want to install on this host: ")
    select choice in "Elasticsearch" "Logstash" "Kibana" Exit
    do
        case $choice in
            "Elasticsearch")
                echo -e "${Light_Green}[ + ]${NC} You have chosen to install ${Light_Cyan}${choice}${NC}"
                echo -e "${Orange}[ ! ]${NC} Downloading $choice installer... "
                wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.16.0-amd64.deb
                echo -e "${Light_Green}[ + ]${NC} ${Light_Cyan}${choice}${NC} installer has been downloaded."
                echo -e "${Light_Green}[ + ]${NC} ${Light_Cyan}${choice}${NC} installing now."
                dpkg -i elasticsearch-8.16.0-amd64.deb > /home/"${HOMEDIR[$OPT]}"/installation_output.txt
                echo -e "${Light_Green}[ + ]${NC} ${Light_Cyan}${choice}${NC} installation output has been save into /home/${HOMEDIR[$OPT]}/installation_output.txt"
                break
            ;;
            "Logstash")
                echo -e "${Light_Green}[ + ]${NC} You have chosen to install ${Light_Cyan}${choice}${NC}"
                echo -e "${Orange}[ ! ]${NC} Downloading $choice installer... "
                break
            ;;
            "Kibana")
                echo -e "${Light_Green}[ + ]${NC} You have chosen to install ${Light_Cyan}${choice}${NC}"
                echo -e "${Orange}[ ! ]${NC} Downloading $choice installer... "
                wget https://artifacts.elastic.co/downloads/kibana/kibana-8.16.0-amd64.deb
                echo -e "${Light_Green}[ + ]${NC} ${Light_Cyan}${choice}${NC} installer has been downloaded."
                echo -e "${Light_Green}[ + ]${NC} ${Light_Cyan}${choice}${NC} installing now."
                dpkg -i kibana-8.16.0-amd64.deb > /home/"${HOMEDIR[$OPT]}"/installation_output.txt
                echo -e "${Light_Green}[ + ]${NC} ${Light_Cyan}${choice}${NC} installation output has been save into /home/${HOMEDIR[$OPT]}/installation_output.txt"
                break
            ;;
            Exit) 
				echo -e "${Red}[X]${NC} You have selected $choice"
				echo -e "${Red}[X]${NC} Thank you! Bye bye!"
				break
			;;
			*) 
				echo -e "${Red}[-_-\"]${NC} That isn't a listed option. Try Again!"
			;;
        esac
    done
}

function main {
    check_root
    check_users
    update_repo
    install_starship
    install_nala
    install_packages
    echo "Importing Elasticsearch Signing Key..."
    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
    echo "Done"
    choose_installer
}

main