$LOAD_PATH.unshift(File.dirname(__FILE__) + '/lib')
require 'log_consumer/version'

Gem::Specification.new do |gem|
  gem.name        = 'log_consumer'
  gem.version     = LogConsumer::VERSION
  gem.summary     = 'DSL for matching and parsing log entries to place them in ElasticSearch'
  gem.description = 'DSL for matching and parsing log entries to place them in ElasticSearch.  See the README for more information.'
  gem.licenses    = ['Proprietary']
  gem.author      = 'Invoca Development'
  gem.homepage    = 'https://github.com/jebentier/log_consumer'
  gem.email       = 'dev@invoca.com'
  gem.files       = Dir['lib/**/*', 'matchers/**/*', 'templates/**/*']
  gem.bindir      = 'bin'
  gem.executables = 'log-consumer'

  gem.add_runtime_dependency 'ruby-kafka'
  gem.add_runtime_dependency 'elasticsearch'
  gem.add_runtime_dependency 'terminal-table', '= 1.7.3'
  gem.add_runtime_dependency 'thor', '~> 0.19'
  gem.add_runtime_dependency 'json'

  gem.add_development_dependency 'pry', '~> 0.10'
  gem.add_development_dependency 'rspec', '~> 3.5'
  gem.add_development_dependency 'simplecov', '= 0.13.0'
end
