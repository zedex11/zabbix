########configuration selinux and firewalld
sudo setenforce 0
sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config
sudo systemctl disable firewalld 

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
UserParameter=count.files,ls -a /var/log/zabbix/ | wc -l
EOF
sudo sed -i '/127.0.0.1/d' /etc/zabbix/zabbix_agentd.conf
sudo systemctl restart zabbix-agent


########install and configuration tomcat
sudo yum install tomcat -y
sudo yum install tomcat-webapps tomcat-admin-webapps -y
sudo systemctl enable tomcat
sudo systemctl start tomcat
sudo mv /tmp/clusterjsp.war /var/lib/tomcat/webapps/
sudo chmod 775 /var/log/tomcat
sudo chmod 775 /var/log/tomcat/*

sleep 1m
#######script create host on zabbix server##############
sudo yum install jq -y
IP_self=`ip addr list eth0 | grep "  inet " | head -n 1 | cut -d " " -f 6 | cut -d / -f 1`
curl -i -X POST -H 'Content-type:application/json' -d '{"jsonrpc":"2.0","method":"user.login","params":{ "user":"Admin","password":"zabbix"},"auth":null,"id":0}' http://${IP}/zabbix/api_jsonrpc.php | tail -n -1 > token
cat token | jq -r .result > TOKEN
read TOKEN < TOKEN
curl -i -X POST -H 'Content-type:application/json' -d '{"jsonrpc":"2.0","method":"host.create","params":{"host":"Linux server","interfaces":[{"type":1,"main":1,"useip":1,"ip":"$IP_self","dns":"","port":"10050"}],"groups":[{"groupid":"2"}],"templates":[{"templateid":"10001"}]},"auth":"$TOKEN","id":1}' http://${IP}/zabbix/api_jsonrpc.php