require File.expand_path('../spec_helper', __FILE__)
require File.expand_path('../../../lib/dns-propagation', __FILE__)

describe DnsPropagation do
  its(:nameservers) { should be_a Hash }
end