require 'dns-propagation'

module DnsPropagation
	class Lookup
    include Mongoid::Document

    field :query, type: String
    field :ns, type: String
    field :rtype, type: String
    field :answer, type: Array
    field :resolves_to, type: String
    field :ttl, type: Integer
    field :is_auth, type: String
    field :at, type: DateTime

    belongs_to :domain
    belongs_to :snapshot
    
    index({ query: 1, at: 1, rtype: 1 })

    def resolve
      self.query = domain.name
      self.at = Time.now.utc

      answer = resolver.query(query).answer
      if !answer.empty?
        self.answer = answer.map(&:to_s)
        self.ttl = answer.first.ttl
        self.resolves_to = answer.first.value
      end

      #puts({ :q => query, :ns => ns, :resolves_to => resolves_to }.inspect)

      self
    end

    private

    def resolver
      raise RuntimeError, "No nameserver!" unless ns
      @resolver ||= Net::DNS::Resolver.new(
        :nameservers => [IPAddr.new(ns)],
        :recursive => false
      )
    end

  end
end