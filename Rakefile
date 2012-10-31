require "bundler/gem_tasks"

require 'dns-propagation'

task :default do
  DnsPropagation::Checker.new('test.bikepimp.co.uk').go
end
