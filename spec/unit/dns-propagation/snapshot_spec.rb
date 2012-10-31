require 'unit/spec_helper'
require 'dns-propagation'
require 'dns-propagation/domain'
require 'dns-propagation/snapshot'

module DnsPropagation
  describe Snapshot do
    before(:each) do
      @domain = Domain.new(:name => 'test.bikepimp.co.uk')
      @domain.stub(:primary_nameserver_ip).and_return('127.0.0.1')
    end

    subject(:snapshot) do
      Snapshot.new(:domain => @domain)
    end

    it { should have_many :lookups }
    it { should belong_to :domain }

    describe '#snapshot!' do
      before(:each) do 
        @nameservers = ['127.0.0.1', '127.0.0.2']
        snapshot.should_receive(:nameservers).and_return(@nameservers)
      end

      it 'should create lookups' do
        lookup = mock(:save => true, :resolves_to => ['127.0.0.1'], :answer => ['answer']); lookup.stub(:resolve).and_return(lookup)
        snapshot.lookups.should_receive(:build).with(:domain => @domain, :ns => @domain.primary_nameserver_ip).and_return(lookup)
        @nameservers.each do |ns|
          snapshot.lookups.should_receive(:build).with(:domain => @domain, :ns => ns).and_return(lookup)
        end
        snapshot.snapshot!
        snapshot.at.should be_a DateTime
      end
    end

  end
end