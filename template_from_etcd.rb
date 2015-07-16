require 'etcd'
require 'erb'
require 'ostruct'
require 'fileutils'

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

get_etcd_value = Proc.new { |path| 
  if client.exists?(path) 
    client.get(path).value
  end
}

write_conf = Proc.new { |output, template|
  config = ERB.new(File.read(template)).result(binding)

  File.open(output, File::CREAT|File::TRUNC|File::RDWR, 0644) do |file|
    file.write(config)
  end
}

papertrail_host = get_etcd_value.call("#{etcd_path}/papertrail_host")

papertrail_port = get_etcd_value.call("#{etcd_path}/papertrail_port")

papertrail_config = "/etc/rsyslog.d/paperweight.conf"

if papertrail_host && papertrail_host
  binding = OpenStruct.new(papertrail_host: papertrail_host, 
                    papertrail_port: papertrail_port).send(:binding)
  write_conf.call(papertrail_config, "/root/paperweight.conf.erb", binding)
else
  File.rename papertrail_config, papertrail_config + '.bak' if File.exists? papertrail_config
end

loggly_token = get_etcd_value.call("#{etcd_path}/loggly_token")

loggly_tag = get_etcd_value.call("#{etcd_path}/loggly_tag") 

loggly_config = "/etc/rsyslog.d/loggly.conf"

if loggly_token && loggly_tag
  binding = OpenStruct.new(loggly_token: loggly_token, loggly_tag: loggly_tag). send(:binding)
  write_conf.call(loggly_config, "/root/loggly.conf.erb", binding )
else
  File.rename loggly_config, loggly_config + '.bak' if File.exists? loggly_config
end

logentries_token = get_etcd_value.call("#{etcd_path}/logentries_token")

logentries_config = "/etc/rsyslog.d/logentries.conf"

if logentries_token
  binding = OpenStruct.new(logentries_token: logentries_token).send(:binding)
  write_conf.call(logentries_config, "/root/logentries.conf.erb", binding )
else
  File.rename logentries_config, logentries_config + '.bak' if File.exists? logentries_config
end

binding = OpenStruct.new(external_port: external_port).send(:binding)
write_conf.call("/etc/rsyslog.conf", "/root/rsyslog.conf.erb", binding)

