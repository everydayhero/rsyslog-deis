require 'etcd'

# DEBUG enables verbose output if set
# ETCD_PORT sets the TCP port on which to connect to the local etcd daemon (default: 4001)
# ETCD_PATH sets the etcd directory where the logger announces its configuration (default: /deis/logger)
# ETCD_TTL sets the time-to-live before etcd purges a configuration value, in seconds (default: 10)
# PORT sets the TCP port on which the logger listens (default: 514)

debug = ENV['DEBUG'] || 0
host = ENV['HOST'] || '127.0.0.1'
etcd_port = ENV['ETCD_PORT'] || '4001'
etcd_path = ENV['ETCD_PATH'] || '/deis/logs'
etcd_ttl = ENV['ETCD_TTL'] || '20'
# port can only be 514 due to the container exposing that port only
port = '514'
timeout = 10


while true do
  begin
    client = Etcd.client(host: host, port: etcd_port)
    client.set("#{etcd_path}/host", value: host, ttl: etcd_ttl)
    client.set("#{etcd_path}/port", value: port, ttl: etcd_ttl)
    sleep(timeout)
  rescue
  end
end