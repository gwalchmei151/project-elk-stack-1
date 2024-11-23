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

    ![software seleciton screenshot](/assets/software-selection.png)

### Initial Setup
- Start HTTP server to download the script from my main machine
![](/assets/transferinitialscript.png)
- `su -` to change to root user (because we do not have sudo yet 🥲)
- Run script - then make like Simba🦁 and fall in love with Nala
![nala](/assets/nala.png)
- Add users to sudo group - usermod -aG sudo <username\>
![](/assets/usermodag-users.png)
- **OPTIONAL** - This is really a personal preference thing, but i am going to install the starship prompt with 
    ```bash 
    curl -sS https://starship.rs/install.sh | sh
    ```
    ![](/assets/starship-install.png)
    I then download my personal config into a `.config` folder
    ```bash
    wget https://raw.githubusercontent.com/gwalchmei151/tushar-personal-configs/refs/heads/main/starship.toml
    ```
    ![](/assets/starship-tushar.png)

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
        ![](/assets/interfaces-file-original.png)
    - To this
        - Elastic
            ![](/assets/interfaces-elastic-edited.png)
        - Kibana
            ![](/assets/interfaces-kibana-edited.png)
-  Restart network with 
    ```bash
    sudo systemctl restart networking 
    ```

## Elasticsearch
### Installation


## Kibana
### Installation