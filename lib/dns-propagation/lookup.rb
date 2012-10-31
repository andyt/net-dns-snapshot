require 'dns-propagation'

Mongoid.load!("config/mongoid.yml", ENV['RACK_ENV'])

module DnsPropagation
	class Lookup
    include Mongoid::Document

    field :query, type: String
    field :ns, type: String
    field :rtype, type: String
    field :answer, type: Array
    field :ttl, type: Integer
    field :is_auth, type: String
    field :at, type: DateTime

    belongs_to :domain
    belongs_to :snapshot
    
    index({ query: 1, at: 1, rtype: 1 })

    def resolve
      self.query = domain.name
      answer = resolver.query(query).answer
      self.answer = answer.map(&:to_s)
      self.at = Time.now.utc
      self.ttl = answer.first.ttl unless answer.empty?
      self
    end

    private

    def resolver
      raise RuntimeError, "No nameserver!" unless ns
      @resolver ||= Net::DNS::Resolver.new(
        :nameservers => [IPAddr.new(ns)],
        :recursive => true
      )
    end

  end
end