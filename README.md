rsyslog-deis
============

Function
--------
This is a replacement logger for the existing deis logger, which uses rsyslog to send your logs to [papertrail](https://papertrailapp.com/) and/or [loggly](http://www.loggly.com/)

Operation
---------
The logger can be used in deis by setting:
    
    deisctl config logger set image=everydayhero/rsyslog-deis:latest

The logger for keys for papertrail and loggly in etcd and will configure accordingly. Those can be set with: 

    etcdctl set /deis_rsyslog/papertrail_host <host>.papertrailapp.com && etcdctl set /deis_rsyslog/papertrail_port <port>
and:

    etcdctl set /deis_rsyslog/loggly_token <token> && etcdctl set /deis_rsyslog/loggly_tag <tag>

Changes
-------
Feel free to add any log publishers and create a pull request. 
