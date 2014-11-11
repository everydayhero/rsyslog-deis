#!/bin/bash

cd /root

/usr/bin/ruby /root/template_from_etcd.rb

/usr/bin/ruby /root/set_etcd_from_env.rb & 

exec /usr/sbin/rsyslogd -n