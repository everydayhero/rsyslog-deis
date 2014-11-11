rsyslog-deis
============

Function
--------
This is a replacement logger for the existing deis logger, which uses rsyslog to send your logs to [papertrail](https://papertrailapp.com/).

Operation
---------
The logger can be used in deis by setting:
~~ deisctl config logger set image=everydayhero/rsyslog-deis:latest ~~

The logger will wait until you have set the keys for the papertrail host in etcd with: 

~~ etcdctl set /deis_rsyslog/host <host>.papertrailapp.com && etcdctl set /deis_rsyslog/port <port> ~~

Changes
-------
Feel free to add any log publishers and create a pull request. 
