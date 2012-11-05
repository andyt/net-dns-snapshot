require 'rubygems'
require 'bundler/setup'
require 'sinatra/base'
require 'dns-propagation'

module DnsPropagation
  class App < Sinatra::Base

    set :root, File.expand_path('../../../', __FILE__)

    class << self
      def start
        Thread.new do
          sleep 60
        end
      end

      def domain
        @domain ||= Domain.find_or_create_by(:name => 'test.bikepimp.co.uk')
      end
    end

    #start

    get '/' do
      @domain = domain
      @snapshots = @domain.snapshots.order_by([:at, -1]).limit(50)
      if @snapshots.first.at < Time.now - 60
        @snapshots.unshift(Snapshot.new(:domain => @domain).tap do |s|
          s.snapshot!
          s.save
        end)
      end
      erb :'/domain'
    end

    def domain
      self.class.domain
    end

  end
end