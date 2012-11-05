require 'dns-propagation'
require 'retryable'

module DnsPropagation
	class Domain
    include Mongoid::Document
    include Retryable

    field :name, type: String
    field :domain, type: String
    field :created_at, type: DateTime

    #index(name: 1)

    has_many :lookups
    has_many :snapshots

    def name=(value)
      super.tap do
        self.domain = PublicSuffix.parse(value).domain
      end
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
      retryable(:tries => 5, :on => Net::DNS::Resolver::NoResponseError) do
        @primary_nameserver ||= resolver.query(domain, Net::DNS::NS).answer.map(&:value).sort.first
      end
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