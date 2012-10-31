require 'dns-propagation'

module DnsPropagation
  class Snapshot
    include Mongoid::Document

    field :at, type: DateTime
    #field :nameservers, type: Array
    field :count_queried, type: Integer
    field :count_current, type: Integer
    field :count_lagging, type: Integer

    belongs_to :domain
    has_many :lookups

    def snapshot!
      self.at = Time.now
      auth_lookup = lookups.build(:domain => domain, :ns => domain.primary_nameserver_ip)
      auth_lookup.resolve.save
      nameservers.each do |ns|
        lookup = lookups.build(:domain => domain, :ns => ns)
        lookup.resolve.save
      end
    end

    def nameservers
      DnsPropagation.nameservers.values.flatten
    end

  end
end