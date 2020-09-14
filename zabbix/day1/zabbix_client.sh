########install and configuration zabbix-agent
sudo yum install -y https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm
sudo yum install -y zabbix-agent
sudo cat<<EOF>>/etc/zabbix/zabbix_agentd.conf
Server=${IP}
ListenPort=10050
ListenIP=0.0.0.0
ServerActive=${IP}
Hostname=client
HostnameItem=system.hostname
HostMetadataItem=system.uname
EOF
sudo sed -i '/127.0.0.1/d' /etc/zabbix/zabbix_agentd.conf
sudo systemctl restart zabbix-agent