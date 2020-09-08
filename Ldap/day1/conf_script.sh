#!/bin/bash
sudo yum install openldap openldap-servers openldap-clients -y
sudo systemctl start slapd
sudo systemctl enable slapd
sudo firewall-cmd --add-service=ldap 
slappasswd -s ${PASSWD} > HASH
read HASH < HASH
tar -xzf /tmp/files.gz
sed -i '/olcRootPW:/s/PASSWORD/'$HASH'/' files/ldaprootpasswd.ldif
sed -i '/olcRootPW:/s/PASSWORD/'$HASH'/' files/ldapdomain.ldif
sed -i '/userPassword:/s/PASSWORD/'$HASH'/' files/ldapuser.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f files/ldaprootpasswd.ldif 
sudo cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
sudo chown -R ldap:ldap /var/lib/ldap/DB_CONFIG
sudo systemctl restart slapd
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif 
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif
sudo ldapmodify -Y EXTERNAL -H ldapi:/// -f files/ldapdomain.ldif
sudo ldapadd -x -D cn=Manager,dc=devopsldab,dc=com -w ${PASSWD} -f files/baseldapdomain.ldif
sudo ldapadd -x -w ${PASSWD} -D "cn=Manager,dc=devopsldab,dc=com" -f files/ldapgroup.ldif
sudo ldapadd -x -D cn=Manager,dc=devopsldab,dc=com -w ${PASSWD} -f files/ldapuser.ldif
sudo yum --enablerepo=epel -y install phpldapadmin
sudo sed -i '398d' /etc/phpldapadmin/config.php
sudo sed -i '397s/\/\// /' /etc/phpldapadmin/config.php
sudo sed -i '/Require local/s/Require local/Require all granted/' /etc/httpd/conf.d/phpldapadmin.conf
sudo systemctl restart httpd