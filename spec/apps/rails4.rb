require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
#require "rails/test_unit/railtie"
require 'action_view/testing/resolvers'

require 'egregious' # our gem

# monkey patch - we don't want fixtures loaded, because we don't configure or test ActiveRecord
# https://github.com/rspec/rspec-rails/issues/1416
module ActiveRecord
  module TestFixtures
    def before_setup
      super
    end
    def after_teardown
      super

    end
  end
end

module Rails4
  class Application < Rails::Application
    config.root = File.expand_path("../../..", __FILE__)
    config.cache_classes = true

    config.eager_load = false
    config.serve_static_assets  = true
    config.static_cache_control = "public, max-age=3600"

    config.consider_all_requests_local       = true
    config.action_controller.perform_caching = false

    config.action_dispatch.show_exceptions = false

    config.action_controller.allow_forgery_protection = false

    config.active_support.deprecation = :stderr

    config.middleware.delete "Rack::Lock"
    config.middleware.delete "ActionDispatch::Flash"
    config.middleware.delete "ActionDispatch::BestStandardsSupport"
    config.middleware.delete ActiveRecord::Migration::CheckPending
    config.middleware.delete ActiveRecord::ConnectionAdapters::ConnectionManagement
    config.middleware.delete ActiveRecord::QueryCache
    config.secret_key_base = '49837489qkuweoiuoqwehisuakshdjksadhaisdy78o34y138974xyqp9rmye8yrpiokeuioqwzyoiuxftoyqiuxrhm3iou1hrzmjk'
    routes.append do
      get "/" => "welcome#index"
      get "/" => "fake#test"
    end
  end
end

class WelcomeController < ActionController::Base
  include Rails.application.routes.url_helpers
  layout 'application'
  self.view_paths = [ActionView::FixtureResolver.new(
    "layouts/application.html.erb" => '<%= yield %>',
    "welcome/index.html.erb"=> 'Hello from index.html.erb',
  )]

  def index
  end

end

Rails4::Application.initialize!
