source "http://rubygems.org"

# Specify your gem's dependencies in egregious.gemspec
gemspec

rails_version = ENV["RAILS_VERSION"] || "default"

rails = case rails_version
when "master"
  {github: "rails/rails"}
when "default"
  ">= 3.1.0"
else
  "~> #{rails_version}"
end

gem "rails", rails

if RUBY_VERSION < '1.9'
  gem 'mongoid', '< 3'
  gem 'bson_ext'
else
  gem 'mongoid'
end