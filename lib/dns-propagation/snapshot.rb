require 'dns-propagation'
require 'retryable'

module DnsPropagation
  class Snapshot
    include Mongoid::Document
    include Retryable

    field :at, type: DateTime
    field :resolves_to, type: String
    field :primary_nameserver, type: String
    #field :nameservers, type: Array
    field :count_queried, type: Integer, default: 0
    field :count_current, type: Integer, default: 0
    field :count_lagging, type: Integer, default: 0
    field :ok, type: Boolean

    belongs_to :domain
    has_many :lookups

    def snapshot!
      self.at = Time.now
      self.resolves_to = auth_lookup.resolves_to
      self.primary_nameserver = domain.primary_nameserver
      threads = []
      nameservers.each do |ns|
        threads << Thread.new do 
          retryable(:tries => 5, :on => Net::DNS::Resolver::NoResponseError) do
            ns_lookups << lookups.build(:domain => domain, :ns => ns).resolve.tap { |l| l.save }
          end
        end
      end
      threads.each { |t| t.join }
      analyse
    end

    def auth_lookup 
      @auth_lookup ||= lookups.build(:snapshot => self, :domain => domain, :ns => domain.primary_nameserver_ip).resolve.tap do |lookup| 
        lookup.save
      end
    end

    private

    def previous
      raise ArgumentError, ":at not set" unless self.at
      @previous ||= Snapshot.order([:at, 1]).where(:at < self.at).first
    end

    def analyse
      ns_lookups.each do |ns_lookup|
        if ns_lookup.answer
          if ns_lookup.resolves_to == auth_lookup.resolves_to
            self.count_current += 1
          else
            self.count_lagging += 1
          end
          self.count_queried += 1
        end
      end
      self.ok = (count_current == count_queried)
    end

    def ns_lookups
      @ns_lookups ||= []
    end

    def nameservers
      DnsPropagation.nameservers.values.flatten
    end

  end
end