# -*- encoding: utf-8 -*-
require File.expand_path('../lib/redis_triple/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Shane Wolf"]
  gem.email         = ["shanewolf@gmail.com"]
  gem.description   = %q{Janktastic Triple Store in Redis}
  gem.summary       = %q{Janktastic Triple Store in Redis}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "redis_triple"
  gem.add_dependency 'redis'
  gem.require_paths = ["lib"]
  gem.version       = RedisTriple::VERSION
end
