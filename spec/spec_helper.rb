require 'rubygems'
require 'bundler/setup'
require 'bundler'
Bundler.setup

ENV["RAILS_ENV"] ||= "test"
require 'active_support'
require 'active_support/test_case'
require 'warden'
require 'cancan'

require 'egregious' # and any other gems you need

RSpec.configure do |config|
  # some (optional) config here
end