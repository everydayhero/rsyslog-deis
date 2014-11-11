require 'etcd'
require 'erb'
require 'ostruct'

# DEBUG enables verbose output if set
# ETCD_PORT sets the TCP port on which to connect to the local etcd daemon (default: 4001)
# ETCD_PATH sets the etcd directory where the logger announces its configuration (default: /deis/logger)
# ETCD_TTL sets the time-to-live before etcd purges a configuration value, in seconds (default: 10)
# PORT sets the TCP port on which the logger listens (default: 514)


host = ENV['HOST'] || '127.0.0.1'
etcd_port = ENV['ETCD_PORT'] || '4001'
etcd_path = ENV['ETCD_RSYSLOG_PATH'] || '/deis_rsyslog'
# external_port can only be 514 due to the container exposing that port only
external_port = '514'

client = Etcd.client(host: host, port: etcd_port)

get_when_exists = Proc.new {|path| 
  while not client.exists?(path) do 
    sleep(1)
  end
  client.get(path).value
}

host_value = get_when_exists.call("#{etcd_path}/host")

port_value = get_when_exists.call("#{etcd_path}/port")

write_conf = Proc.new { |output, template|
  config = ERB.new(File.read(template)).result(
    OpenStruct.new(host_value: host_value, port_value: port_value).send(:binding))

  File.open(output, File::CREAT|File::TRUNC|File::RDWR, 0644) do |file|
    file.write(config)
  end
}

write_conf.call("/etc/rsyslog.d/paperweight.conf", "paperweight.conf.erb")
write_conf.call("/etc/rsyslog.conf", "rsyslog.conf.erb")

