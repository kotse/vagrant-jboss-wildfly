#!/bin/bash

conf_folder=$1

function print_help() {
  echo "Usage: $0 conf_folder"
}

if [ -z "$conf_folder" ]; then
  print_help
  exit 1
fi

#install vim
apt-get update
apt-get install -y vim

#install java8
echo "deb http://http.debian.net/debian jessie-backports main" > /etc/apt/sources.list.d/backports.list
apt-get update
apt-get install -y -t jessie-backports openjdk-8-jdk

#install wildfly
cd /tmp
wget http://download.jboss.org/wildfly/9.0.2.Final/wildfly-9.0.2.Final.tar.gz
cd /usr/local/
tar xfz /tmp/wildfly-9.0.2.Final.tar.gz
mv wildfly-9.0.2.Final wildfly
rm /tmp/wildfly-9.0.2.Final.tar.gz

#copy wildfy configuration
cd /usr/local
cp $conf_folder/wildfly-conf/wildfly-start.sh $conf_folder/wildfly-conf/standalone.conf wildfly/bin/

#setup wildfly user
useradd -d /home/wildfly -m -s/bin/sh -U -u 2000 wildfly
chown -R wildfly.wildfly wildfly/standalone

#setup log folder
mkdir /var/log/wildfly && \
  chown wildfly.wildfly /var/log/wildfly

#setup wildfly as a service
cp $conf_folder/wildfly-conf/wildfly.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable wildfly.service
systemctl start wildfly.service

#waiting for boot
while ! /usr/local/wildfly/bin/jboss-cli.sh -c "ls" 2>&1 >/dev/null ; do echo Waiting for wildfly... ; sleep 1; done

#deploy all projects found in deploy/
for proj_war in $conf_folder/deploy/*.war; do
  echo "deplying $proj_war"
  /usr/local/wildfly/bin/jboss-cli.sh -c "deploy $proj_war"
done
