#!/bin/bash

conf_folder=$1

function print_help() {
  echo "Usage: $0 conf_folder"
}

if [ -z "$conf_folder" ]; then
  print_help
  exit 1
fi

#install java 7
apt-get -y install openjdk-7-jdk

#install jboss 7
cd /tmp
wget http://download.jboss.org/jbossas/7.1/jboss-as-7.1.1.Final/jboss-as-7.1.1.Final.zip
cd /usr/local/
apt-get install unzip
unzip /tmp/jboss-as-7.1.1.Final.zip
mv jboss-as-7.1.1.Final jboss

#copy jboss configuration
cd /usr/local
cp $conf_folder/jboss-conf/jboss-start.sh $conf_folder/jboss-conf/standalone.conf jboss/bin/

#setup jboss user
useradd -d /home/jboss -m -s/bin/sh -U -u 2000 jboss
chown -R jboss.jboss jboss/standalone

#setup log folder
mkdir /var/log/jboss && \
  chown jboss.jboss /var/log/jboss

#setup jboss as a service
cp $conf_folder/jboss-conf/jboss.service /etc/systemd/system/
systemctl daemon-reload 
systemctl enable jboss.service
systemctl start jboss.service

#waiting for boot
while ! /usr/local/jboss/bin/jboss-cli.sh -c "ls" 2>&1 >/dev/null ; do echo Waiting for jboss... ; sleep 1; done

#deploy all projects found in deploy/
for proj_war in $conf_folder/deploy/*.war; do
  echo "deplying $proj_war"
  /usr/local/jboss/bin/jboss-cli.sh -c "deploy $proj_war"
done
