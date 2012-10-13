# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rubbish_collection/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Craig R Webster"]
  gem.email         = ["craig@barkingiguana.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "rubbish_collection"
  gem.require_paths = ["lib"]
  gem.version       = RubbishCollection::VERSION

  gem.add_runtime_dependency 'local_authority', '~> 0.0.4'
end
