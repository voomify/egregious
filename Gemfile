source "http://rubygems.org"

# Specify your gem's dependencies in egregious.gemspec
gemspec

if RUBY_VERSION < '1.9'
  gem 'mongoid', '< 3'
  gem 'bson_ext'
else
  gem 'mongoid', '>= 3'
end