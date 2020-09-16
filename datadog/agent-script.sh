########install datadog agent#########
#${KEY} - input variables from terraform (api_key datadog)
DD_AGENT_MAJOR_VERSION=7 DD_API_KEY=${KEY} DD_SITE="datadoghq.eu" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"


########install tomcat###############
sudo yum install tomcat -y
sudo yum install tomcat-webapps tomcat-admin-webapps -y
sudo systemctl enable tomcat
sudo systemctl start tomcat
sudo chmod 755 /var/log/tomcat
sudo chmod 755 /var/log/tomcat/*

#########install apache###############
sudo yum install httpd -y
sudo systemctl enable httpd
sudo systemctl start httpd
sudo chmod 755 /etc/httpd/*



#########configuration datadog agent#############
sudo echo -e "\nlogs_enabled: true" >> /etc/datadog-agent/datadog.yaml

sudo cat<<EOF>/etc/datadog-agent/conf.d/http_check.d/conf.yaml
instances:
  - name: tut.by
    url: https://tut.by
EOF

sudo mkdir /etc/datadog-agent/conf.d/httpd.d
sudo cat<<EOF>/etc/datadog-agent/conf.d/httpd.d/conf.yaml
logs:
  - type: file
    path: /etc/httpd/logs/*
    source: httpd
    service: httpd
EOF

sudo cat<<EOF>/etc/datadog-agent/conf.d/tomcat.d/log.yaml
logs:
  - type: file
    path: /var/log/tomcat/*
    service: tomcat
    source: tomcat
EOF

sudo systemctl restart datadog-agent