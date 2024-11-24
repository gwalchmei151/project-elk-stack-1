# ELK Stack Implementation

## Preamble
*As usual my writing is going to be more stream of consciousness and commentary than professional - but plenty of professional around anyway*

Well, here we go again, for the fourth time over, during which I have burnt through about 12 VMs and have still been unable to make Kibana and Elastic talk to each other. Maybe they need couple's therapy instead? 

I'm also doing this to create a comprehensive checklist of the steps that need to be done to ensure that the SIEM ecosystem works when installed across multiple hosts with security enabled. And none of the documentation I've seen seems to do that just yet. 

The general plan is to setup Elasticsearch and Kibana first and make sure those two can talk to each other. Then setup Logstash and ensure it can communicate with the system, and finally a honeypot to send logs to Logstash.

Here goes...

## VM
### Base Install
- Components:
    - Elasticsearch
    - Kibana
- OS: Debian 12
    - Default options
- Hostnames:
    - elastic - for the host running elastic
    - kibana - for the host running kibana
- Domain: localdomain
- Software selection
    - No desktop environment
    - Standard system utilities
    - SSH Server

    ![software seleciton screenshot](/assets/BaseInstall/software-selection.png)

### Initial Setup
- Start HTTP server to download the script from my main machine
![](/assets/InitialSetup/transferinitialscript.png)
- `su -` to change to root user (because we do not have sudo yet 🥲)
- Run script - then make like Simba🦁 and fall in love with Nala
![nala](/assets/InitialSetup/nala.png)
- Add users to sudo group - usermod -aG sudo <username\>
![](/assets/InitialSetup/usermodag-users.png)
- **OPTIONAL** - This is really a personal preference thing, but i am going to install the starship prompt with 
    ```bash 
    curl -sS https://starship.rs/install.sh | sh
    ```
    ![](/assets/InitialSetup/starship-install.png)
    I then download my personal config into a `.config` folder
    ```bash
    wget https://raw.githubusercontent.com/gwalchmei151/tushar-personal-configs/refs/heads/main/starship.toml
    ```
    ![](/assets/InitialSetup/starship-tushar.png)

### Networking - Set Static IP
- I also need to set static IPs for both these machines, will be using the steps in this [video](https://youtu.be/O_wlpD9C4HI?si=YmYPKIspRvKuikw1) to do so

- make backup of interface file
    ```bash
    sudo cp /etc/network/interfaces ~/
    ```
- edit interface file
    ```bash
    sudo nano /etc/network/interfaces
    ```
    - Edit this
        ![](/assets//SetStaticIP/interfaces-file-original.png)
    - To this
        - Elastic
            ![](/assets//SetStaticIP/interfaces-elastic-edited.png)
        - Kibana
            ![](/assets//SetStaticIP/interfaces-kibana-edited.png)
-  Restart network with 
    ```bash
    sudo systemctl restart networking 
    ```

## Installation
### Elasticsearch
- Get elasticsearch debian package
    ```bash
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.16.0-amd64.deb
    ```
- Install
    ```bash
    sudo dpkg -i elasticsearch-8.16.0-amd64.deb
    ```
- Take note of [output](/information.md)

### Kibana
- Get kibana debian package
    ```bash
    wget https://artifacts.elastic.co/downloads/kibana/kibana-8.16.0-amd64.deb
    ```
- Install
    ```bash
    sudo dpkg -i kibana-8.16.0-amd64.deb
    ```
- Take note of [output](/information.md)
### Screenshots
![wget packages](/assets/Installation/wget-packages.png)
![dpkg install](/assets/Installation/dpkg-install.png)

## Configuration
### Elasticsearch
1. Configure the network hosts portion of the yml file first
    ```bash
    sudo nano /etc/elasticsearch/elasticsearch.yml
    ```
    ![elasticsearch-yml-network](/assets/Configuration/Elasticsearch/elastic-yml-network.png)

2. Enable elasticsearch - `sudo systemctl enable elasticsearch`
3. Start elastic - `sudo systemctl start elasticsearch`
4. Check status - `sudo systemctl status elasticsearch`
![alt text](/assets/Configuration/Elasticsearch/elastic-enable-start-status.png)
5. Generate passwords for built-in users - `sudo /usr/share/elasticsearch/bin/elasticsearch-setup-passwords interactive`
    - Ran into issue with keystore here and switched into troubleshooting mode, documented [here](./troubleshooting.md)
