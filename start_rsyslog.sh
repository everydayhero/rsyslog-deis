#!/bin/bash

bundle install

ruby template_from_etcd.rb

ruby set_etcd_from_env.rb & 

exec /usr/sbin/rsyslogd -n