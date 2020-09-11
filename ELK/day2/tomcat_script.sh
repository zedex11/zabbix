#!/bin/bash
sudo yum install tomcat -y
sudo yum install tomcat-webapps tomcat-admin-webapps -y
sudo systemctl enable tomcat
sudo systemctl start tomcat
sudo mv /tmp/clusterjsp.war /var/lib/tomcat/webapps/
sudo chmod 775 /var/log/tomcat
sudo chmod 775 /var/log/tomcat/*

#########install and cofiguration logstash############
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
    path => "/var/log/tomcat/*"
    start_position => "beginning"
  }
}
output {
  elasticsearch {
    hosts => ["${IP}:9200"]
  }
  stdout { codec => rubydebug }
}
EOF
sudo systemctl restart logstash
