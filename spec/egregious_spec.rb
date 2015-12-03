require 'spec_helper'

def rescue_from(exception, options)
end

include Egregious

describe Egregious do

  describe 'status_code' do
    it "should translate Symbol to right HTTP STATUS CODE" do
      expect(status_code(:bad_request)).to eq(400)
      expect(status_code(:unauthorized)).to eq(401)
      expect(status_code(:unprocessable_entity)).to eq(422)
    end
  end

  describe 'clean_backtrace ' do
    it "should return nil" do
      expect(clean_backtrace(Exception.new)).to eq(nil)
    end

    it "should return a stack trace" do
      begin
        raise Exception.new
      rescue Exception => exception
        expect(clean_backtrace(exception).size).to be > 0
      end
    end

    it "should remove the beginning of the backtrace" do
      begin
        raise Exception.new
      rescue Exception => exception
        Rails.instance_eval do
          def self.root
            __FILE__
          end
        end
        expect(clean_backtrace(exception)[0]).to match /:\d/
      end
    end
  end

  #
  # Once these codes are published and used in the gem, they should not change.
  # it will break other peoples apis.  This test ensures that.
  # client should use a configuration file to change the mappings themselves
  #
  describe 'exception_codes' do

    it "should return forbidden for SecurityError's'" do
      expect(exception_codes[SecurityError]).to eq(Egregious.status_code(:forbidden))
    end

    if defined?(ActionController)
      it "should return expected errors for ActionController" do
        expect(exception_codes[AbstractController::ActionNotFound]).to eq(Egregious.status_code(:bad_request))
        expect(exception_codes[ActionController::InvalidAuthenticityToken]).to eq(Egregious.status_code(:bad_request))
        expect(exception_codes[ActionController::MethodNotAllowed]).to eq(Egregious.status_code(:not_allowed))
        expect(exception_codes[ActionController::MissingFile]).to eq(Egregious.status_code(:not_found))
        expect(exception_codes[ActionController::RoutingError]).to eq(Egregious.status_code(:bad_request))
        expect(exception_codes[ActionController::UnknownController]).to eq(Egregious.status_code(:bad_request))
        expect(exception_codes[ActionController::UnknownHttpMethod]).to eq(Egregious.status_code(:not_allowed))
        #exception_codes[ActionController::MissingTemplate].should ==  Egregious.status_code(:not_found)
      end
    end

    if defined?(ActiveModel)
      it "should return expected errors for ActiveModel" do
        expect(exception_codes[ActiveModel::MissingAttributeError]).to eq(Egregious.status_code(:bad_request))
      end
    end

    if defined?(ActiveRecord)
      it "should return expected errors for ActiveRecord" do
        expect(exception_codes[ActiveRecord::AttributeAssignmentError]).to eq(Egregious.status_code(:bad_request))
        expect(exception_codes[ActiveRecord::MultiparameterAssignmentErrors]).to eq(Egregious.status_code(:bad_request))
        expect(exception_codes[ActiveRecord::ReadOnlyAssociation]).to eq(Egregious.status_code(:forbidden))
        expect(exception_codes[ActiveRecord::ReadOnlyRecord]).to eq(Egregious.status_code(:forbidden))
        expect(exception_codes[ActiveRecord::RecordInvalid]).to eq(Egregious.status_code(:bad_request))
        expect(exception_codes[ActiveRecord::RecordNotFound]).to eq(Egregious.status_code(:not_found))
        expect(exception_codes[ActiveRecord::UnknownAttributeError]).to eq(Egregious.status_code(:bad_request))
      end
    end

    if defined?(Warden)
      it "should return expected errors for Warden" do
        expect(exception_codes[Warden::NotAuthenticated]).to eq(Egregious.status_code(:unauthorized))
      end
    end

    if defined?(CanCan)
      it "should return expected errors for CanCan" do
        # technically this should be forbidden, but for some reason cancan returns AccessDenied when you are not logged in
        expect(exception_codes[CanCan::AccessDenied]).to eq(Egregious.status_code(:unauthorized))
        expect(exception_codes[CanCan::AuthorizationNotPerformed]).to eq(Egregious.status_code(:unauthorized))
      end
    end

    if defined?(Mongoid)
      it "should return expected errors for Mongoid" do
        expect(exception_codes[Mongoid::Errors::InvalidFind]).to eq(Egregious.status_code(:bad_request))
        expect(exception_codes[Mongoid::Errors::DocumentNotFound]).to eq(Egregious.status_code(:not_found))
        expect(exception_codes[Mongoid::Errors::Validations]).to eq(Egregious.status_code(:unprocessable_entity))
      end

      if defined?(Mongoid::VERSION) && Mongoid::VERSION > '3'
        it "should return expected errors for Mongoid 3+" do
          expect(exception_codes[Mongoid::Errors::ReadonlyAttribute]).to eq(Egregious.status_code(:forbidden))
          expect(exception_codes[Mongoid::Errors::UnknownAttribute]).to eq(Egregious.status_code(:bad_request))
        end
      end
    end
  end

  describe "status_code_for_exception" do
    it 'should return 500 for non-mapped exceptions' do
      expect(exception_codes[Exception]).to eq(nil)
      expect(status_code_for_exception(Exception.new)).to eq(500)
    end
    it 'should allow configuration of exception codes' do
      Egregious.exception_codes.merge!({NameError => "999"})
      expect(status_code_for_exception(NameError.new)).to eq(999)
    end
  end

  describe "build_html_file_path" do
    it "should build a valid path" do
      Rails.instance_eval do
        def self.root
          __FILE__
        end
      end
      expect(build_html_file_path('500')).to eq(File.join(__FILE__, 'public', '500.html'))
    end
  end
end