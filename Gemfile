source 'https://rubygems.org'

# Specify your gem's dependencies in thermostat.gemspec
gemspec

gem 'aasm', '~> 3.1'
gem 'fakefs', '0.5.2', :require => 'fakefs/safe'
gem 'listen', '~> 2.7'
gem 'minitest', '~> 5.3'
gem 'rr', '~> 1.1'
gem 'timers', '~> 2.0.0'

# Not needed directly by the application, but listen requires it and celluloid < 0.16 needs outdated timers that doesn't actually work...
gem 'celluloid', '0.16.0.pre', :git => 'https://github.com/celluloid/celluloid.git'
