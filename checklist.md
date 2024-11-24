# Checklist for ELK Stack Implementation - UNDER CONSTRUCTION

## Elastic
### VM Setup
- [ ] Install Debian VM
- [ ] `apt update`
- [ ] Install the following
    - [ ] nala (**optional** - wrapper for apt)
    - [ ] sudo
    - [ ] net-tools
    - [ ] gnupg2 
    - [ ] apt-transport-https curl vim
    - [ ] curl
    - [ ] vim (**optional** - text editor)
- [ ] Add Elasticsearch Public Signing Key
- [ ] Add local user to sudo group
- [ ] (**OPTIONAL**) Install and configure starship prompt
- [ ] Set static IP
- [ ] Test connection between machines
- [ ] Download `.deb` package and install Elasticsearch

### xpack security
- [ ] Generate Certificate Authority w Password
- [ ] Copy CA certificate to `/etc/elasticsearch/certs/`
- [ ] Generate elasticsearch certs signed by CA (will also be useful for nodes later on) - with password
- [ ] Adjust ownership newly created certificates to root:elastic
- [ ] Adjust read-write permissions of newly created certificates to 660
- [ ] Update keystore.path in yml from transport.p12 to newly generated elasticsearch certs
- [ ] Update truststore.path in yml from transport.p12 to newly generated elasticsearch certs
- [ ] Add `keystore.secure_password` to elasticsearch keystore - Overwrite if need be
- [ ] Add `truststore.secure_password` to elasticsearch keystore - Overwrite if need be
- [ ] Restart Elasticsearch


## Kibana
### VM Setup
- [ ] Install Debian VM
- [ ] `apt update`
- [ ] Install the following
    - [ ] nala (**optional** - wrapper for apt)
    - [ ] sudo
    - [ ] net-tools
    - [ ] gnupg2 
    - [ ] apt-transport-https curl vim
    - [ ] curl
    - [ ] vim (**optional** - text editor)
- [ ] Add Elasticsearch Public Signing Key
- [ ] Add local user to sudo group
- [ ] (**OPTIONAL**) Install and configure starship prompt
- [ ] Set static IP
- [ ] Test connection between machines
- [ ] Download `.deb` package and install Kibana
