require File.expand_path('../../../lib/dns/verifier', __FILE__)
require 'timeout'
require 'net/dns'
require 'net/dns/resolver'
#require 'public_suffix'

module DnsPropagation
  class Checker

    DEFAULTS = {
      :duration => 300,
      :interval => 30
    }

    attr_reader :domain, :options

    def initialize(domain, options = {})
      @options = DEFAULTS.merge(options)
      @domain = PublicSuffix.parse(domain)
    end

    def name_servers
      @name_servers ||= auth_resolver.query(domain.domain, Net::DNS::NS).answer.map(&:value).sort
    end

    def auth_resolver
      @auth_resolver ||= Net::DNS::Resolver.new(:defname => false, :retry => 2)
    end

    def resolver
      @resolver ||= Net::DNS::Resolver.new
    end

    def auth_ips
      resolver.query(domain.to_s, Net::DNS::A).answer.map(&:value)
    end

    def go
      Timeout.timeout(options[:duration]) do
        loop do
          puts "\n\n%s" % Time.now.to_s
          puts "Auth IP: %s" % auth_ips.first
          DnsPropagation.servers.each do |name, servers|
            servers.each do |server|
              DNS.verify(domain).with_server(server).resolves_to(auth_ips.first)
            end
          end
          sleep options[:interval]
        end
      end
    rescue Timeout::Error
      # done
    end

  end
end