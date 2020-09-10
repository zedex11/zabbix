#!/bin/bash

##########install and cofiguration logstash###############
sudo yum install java-1.8.0-openjdk -y
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
sudo cat<<EOF>/etc/yum.repos.d/logstash.repo
[logstash-7.x]
name=Elastic repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF
sudo yum install logstash -y
sudo cat<<EOF>/etc/logstash/conf.d/logstash.conf
input {
  file {
    path => "/var/log/logstash/elk-users.log"
    start_position => "beginning"
  }
}
output {
  elasticsearch {
    hosts => ["localhost:9200"]
  }
  stdout { codec => rubydebug }
}
EOF
sudo systemctl restart logstash


##########install and cofiguration elasticsearch#################

sudo cat<<EOF>/etc/yum.repos.d/elasticsearch.repo
[elasticsearch]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=0
autorefresh=1
type=rpm-md
EOF
sudo yum install --enablerepo=elasticsearch elasticsearch -y
sudo cat<<EOF>>/etc/elasticsearch/elasticsearch.yml
network.host: 0.0.0.0
http.port: 9200
EOF
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable elasticsearch.service
sudo systemctl start elasticsearch.service


#########install and cofiguration kibana############

sudo cat<<EOF>/etc/yum.repos.d/kibana.repo
[kibana-7.x]
name=Kibana repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF
sudo yum install kibana -y
sudo echo -e "\nserver.host: "0.0.0.0"" >> /etc/kibana/kibana.yml
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable kibana.service
sudo systemctl start kibana.service