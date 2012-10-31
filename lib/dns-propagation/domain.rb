require 'dns-propagation'

module DnsPropagation
	class Domain
    include Mongoid::Document

    field :name, type: String
    field :created_at, type: DateTime
    #index(name: 1)

    has_many :lookups
    has_many :snapshots

    def name=(value)
      self[:name] = value
    end

    def resolve
      lookup = Lookup.new(:ns => primary_nameserver_ip, :query => primary_nameserver_ip).resolve
      lookup.answer
    end

    def primary_nameserver_ip
      @primary_nameserver_ip ||= Resolv.getaddress(primary_nameserver)
    end

    private

    def soa
      @soa ||= begin
        result = resolver.query(name, Net::DNS::SOA)
        (result.answer + result.authority).detect { |a| Net::DNS::RR::SOA === a }
      end
    end

    def primary_nameserver
      @primary_nameserver ||= soa.mname
    end

    def whois
      @whois = Whois::Client.new
    end

    def ttl
      soa.ttl
    end

    def resolver
      @resolver ||= Net::DNS::Resolver.new
    end

  end
end