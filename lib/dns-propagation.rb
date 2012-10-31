require "dns-propagation/version"

require 'mongo'
require 'mongoid'
require 'net/dns'
require "public_suffix"

require 'whois'
require 'resolv'
require "yaml"
require "timeout"

require 'dns-propagation/domain'
require 'dns-propagation/lookup'
require 'dns-propagation/snapshot'

module DnsPropagation
  def self.nameservers
    @nameservers ||= begin
      nameservers = YAML.load(File.open(File.expand_path('../../config/servers.yml', __FILE__)))
      nameservers.keys.each do |name|
        nameservers[name] = nameservers[name].select { |ns| resolving?(ns) }
      end
      nameservers
    end
  end

  def self.resolving?(ns)
    Timeout.timeout(1) do 
      Net::DNS::Resolver.new(:nameservers => [ns]).query('www.google.com', Net::DNS::A)
    end
    true
  rescue Exception => e
    false
  end

end
