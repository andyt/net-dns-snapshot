require 'integration/spec_helper'
require 'dns-propagation/snapshot'

module DnsPropagation
  describe Snapshot do

    before(:each) do
      @domain = Domain.new(:name => 'www.google.co.uk')
      @snapshot = Snapshot.new(:domain => @domain)
    end

    it 'should snapshot' do
      @snapshot.snapshot!
      @snapshot.domain.should == @domain
      @snapshot.lookups.count.should == @snapshot.nameservers.size + 1
      @domain.snapshots.size.should == 1
    end

  end
end

