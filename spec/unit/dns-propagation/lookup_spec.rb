require 'unit/spec_helper'
require 'dns-propagation/lookup'

module DnsPropagation
  describe Lookup do
    subject(:lookup) do
      @domain = Domain.new(:name => 'test.bikepimp.co.uk')
      Lookup.new(:domain => @domain, :ns => '127.0.0.1')
    end

    it { should belong_to :domain }
    it { should belong_to :snapshot }

    describe '#resolve' do
      it 'should set value, ttl and time' do
        lookup.resolve
        lookup.query.should == @domain.name
        lookup.answer.size.should == 2
        lookup.answer.first.should be_a String   # Net::DNS::RR::CNAME
        lookup.at.should be_a DateTime
        lookup.ttl.should be_a Integer
      end
    end
  end
end