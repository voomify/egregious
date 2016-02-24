require 'spec_helper'


def rescue_from(exception, options)
end

def airbrake_request_data
  {}
end

%w(env params session).each do |store|
  eval <<-RX
    def #{store}
      {}
    end
  RX
end

include Egregious

describe Egregious do

  context "notify_airbrake 4" do
    class Airbrake
          def self.notify_or_ignore(*params)
          end
    end
    it "should call notify_or_ignore" do
      expect(Airbrake).to receive(:notify_or_ignore)
      notify_airbrake(nil)
    end
  end
  context "notify_airbrake 5" do
      class Airbrake::Rack::NoticeBuilder
        def initialize(env);end
        def build_notice(exception);end
      end

      class << Airbrake
        remove_method :notify_or_ignore
        def self.notify(*params)
        end
      end
      it "should call notify" do
        expect(Airbrake).to receive(:notify)
        notify_airbrake(nil)
      end
    end
end