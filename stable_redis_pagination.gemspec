require File.expand_path('../lib/stable_redis_pagination/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Ian Pearce', 'Noah Thorpe']
  gem.email         = ['ian@ianpearce.org']
  gem.description   = %q{Paginate things via after_id and count using Redis sorted sets}
  gem.summary       = %q{"Stable" Pagination with Redis}
  gem.homepage      = 'https://github.com/yerdle/stable_redis_pagination'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'stable_redis_pagination'
  gem.require_paths = ['lib']
  gem.version       = StableRedisPagination::VERSION

  gem.add_dependency('redis')
  gem.add_development_dependency('rake')
  gem.add_development_dependency('rspec')
end
