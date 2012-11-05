require 'dns-propagation'

# This models a nameserver updating its entries for ++domain++
# from one value to another at a given point in time.
#
# It provides an estimate of the effective TTL seen at that nameserver.
module DnsPropagation
  class Migration
    include Mongoid::Document

    belongs_to :domain
    #belongs_to :lookup

    field :from, type: String
    field :to, type: String
    field :ns, type: String
    field :at, type: DateTime
    field :min_ttl, type: Integer
    field :max_ttl, type: Integer

    index({ domain: 1, from: 1, to: 1 })

  end
end