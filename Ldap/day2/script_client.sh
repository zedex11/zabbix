#Installation and configuration ldap client-server interaction  
sudo yum -y install openldap-clients nss-pam-ldapd
ldapserver="ldap://${IP}"
ldapbasedn="dc=devopsldab,dc=com"
sudo authconfig --enableldap --enableldapauth --ldapserver=${IP} --ldapbasedn="dc=devopsldab,dc=com" --enablemkhomedir --update
sudo sed -i 's/127.0.0.1/'${IP}'/' /etc/nslcd.conf
sudo sed -i '/base/d' /etc/nslcd.conf
sudo echo -e "\nbase dc=devopsldab,dc=com" >> /etc/nslcd.conf

#creating a script for ssh conections to client whitch will check users public keys
sudo cat<<EOF>/opt/ssh_ldap.sh
#! /bin/bash
/usr/bin/ldapsearch -x '(&(objectClass=posixAccount)(uid='"\$1"'))' 'sshPublicKey' | sed -n '/^ /{H;d};/sshPublicKey:/x;\$g;s/\n *//g;s/sshPublicKey: //gp'
EOF
sudo chmod +x /opt/ssh_ldap.sh

#configuration ssh-client
sudo cat<<EOF>>/etc/ssh/sshd_config
AuthorizedKeysCommand /opt/ssh_ldap.sh
AuthorizedKeysCommandUser nobody
EOF
sudo systemctl restart sshd

