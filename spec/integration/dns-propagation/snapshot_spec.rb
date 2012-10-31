require 'integration/spec_helper'
require 'dns-propagation/snapshot'

module DnsPropagation
  describe Snapshot do

    before(:each) do
      @domain = Domain.new(:name => 'www.armakuni.com')
      @snapshot = Snapshot.new(:domain => @domain)
    end

    it 'should snapshot' do
      @snapshot.snapshot!
      @snapshot.domain.should == @domain
      @snapshot.lookups.count.should == @snapshot.send(:nameservers).size + 1
      @domain.snapshots.size.should == 1
      @snapshot.count_current.should == @snapshot.count_queried
    end

  end
end

