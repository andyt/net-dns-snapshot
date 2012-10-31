require 'mongoid-rspec'

RSpec.configure do |configuration|
  configuration.include Mongoid::Matchers
end

ENV['RACK_ENV'] ||= 'test'