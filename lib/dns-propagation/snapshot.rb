require 'dns-propagation'

module DnsPropagation
  class Snapshot
    include Mongoid::Document

    field :at, type: DateTime
    #field :nameservers, type: Array
    field :count_queried, type: Integer, default: 0
    field :count_current, type: Integer, default: 0
    field :count_lagging, type: Integer, default: 0

    belongs_to :domain
    has_many :lookups

    def snapshot!
      self.at = Time.now      
      nameservers.each do |ns|
        begin
          ns_lookups << lookups.build(:domain => domain, :ns => ns).resolve.tap { |l| l.save }
        rescue Net::DNS::Resolver::NoResponseError
          # NOOP
        end
      end
      analyse
    end

    def auth_lookup 
      @auth_lookup ||= lookups.build(:domain => domain, :ns => domain.primary_nameserver_ip).resolve.tap { |l| l.save }
    end

    private

    def analyse
      ns_lookups.each do |ns_lookup|
        if ns_lookup.resolves_to == auth_lookup.resolves_to
          self.count_current += 1
        else
          self.count_lagging += 1
        end
        self.count_queried += 1
      end
    end

    def ns_lookups
      @ns_lookups ||= []
    end

    def nameservers
      DnsPropagation.nameservers.values.flatten
    end

  end
end