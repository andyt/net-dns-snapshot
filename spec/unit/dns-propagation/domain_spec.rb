require 'unit/spec_helper'
require 'dns-propagation'
require 'dns-propagation/domain'

module DnsPropagation
  describe Domain do
    subject(:domain) do
      Domain.new(:name => 'test.bikepimp.co.uk')
    end

    it { should have_many :lookups }
    it { should have_many :snapshots }

    its(:name) do
      should == 'test.bikepimp.co.uk'
    end

    its(:soa) do
      should be_a Net::DNS::RR::SOA
    end

    its(:primary_nameserver) do
      should == 'ns1.rimuhosting.com.'
    end

    its(:domain) do
      should == 'bikepimp.co.uk'
    end

    its(:primary_nameserver_ip) do
      should == '66.199.228.130'
    end

    describe '#resolve' do
      before(:each) do
        Lookup.stub_chain(:new, :resolve).and_return(mock(:answer => ['whatever.co.uk.']))
      end
      it 'should resolve' do
        domain.resolve.first.should == 'whatever.co.uk.'
      end
    end

    its(:ttl) do
      should be_a Integer
    end

  end
end