require 'spec_helper'

class FakeController < ActionController::Base
  include Egregious
  def test
    head :ok
  end
end

#ActionDispatch::Routing::Routes.add_route('fake_page/test', :controller => 'fake_page', :action => 'test')

describe 'ShowPageModules', ' included in a ' do
  describe FakeController do

    it "declares a before filter that sets the variable" do
      get :test
      expect(assigns(:fancy_page)).to be nil
    end
  end
end