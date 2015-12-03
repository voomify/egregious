$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
ENV["RAILS_ENV"] ||= "test"

require 'rubygems'
require 'bundler/setup'
require 'bundler'
Bundler.setup

require 'active_support'
#require 'active_support/test_case'
require 'action_controller'
require 'warden'
require 'cancan'
require 'mongoid'

#root = File.expand_path(File.dirname(__FILE__))

ENV["RAILS_ENV"] = "test"
require "rails"
case Rails.version
when '3.2.22'
  require "apps/rails3_2"
when '4.2.5'
  require "apps/rails4"
end

require 'rspec/rails'

RSpec.configure do |config|
  #config.rspec_opts = '--format documentation'
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!
end

Test::Unit::AutoRunner.need_auto_run = false if defined?(Test::Unit::AutoRunner)
