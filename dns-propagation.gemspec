# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dns-propagation/version'

Gem::Specification.new do |gem|
  gem.name          = "dns-propagation"
  gem.version       = Dns::Propagation::VERSION
  gem.authors       = ["Andy Triggs"]
  gem.email         = ["andy.triggs@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'net-dns'
  gem.add_dependency 'whois'
  gem.add_dependency 'mongo'
  gem.add_dependency 'bson_ext'
  gem.add_dependency 'mongoid'

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'mongoid-rspec'
  gem.add_development_dependency 'guard'
  gem.add_development_dependency 'guard-rspec'
  gem.add_development_dependency 'rb-readline'
  gem.add_development_dependency 'rb-inotify'
end
