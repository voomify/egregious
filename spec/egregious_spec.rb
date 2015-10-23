require 'spec_helper'

def rescue_from(exception, options)
end

include Egregious

describe Egregious do

  describe 'status_code' do
    it "should translate Symbol to right HTTP STATUS CODE" do
      status_code(:bad_request).should == 400
      status_code(:unauthorized).should == 401
      status_code(:unprocessable_entity).should == 422
    end
  end

  describe 'clean_backtrace ' do
    it "should return nil" do
      clean_backtrace(Exception.new).should == nil
    end

    it "should return a stack trace" do
      begin
        raise Exception.new
      rescue Exception => exception
        clean_backtrace(exception).size.should be > 0
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
        clean_backtrace(exception)[0].should match /:\d/
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
      exception_codes[SecurityError].should == Egregious.status_code(:forbidden)
    end

    if defined?(ActionController)
      it "should return expected errors for ActionController" do
        exception_codes[AbstractController::ActionNotFound].should == Egregious.status_code(:bad_request)
        exception_codes[ActionController::InvalidAuthenticityToken].should == Egregious.status_code(:bad_request)
        exception_codes[ActionController::MethodNotAllowed].should == Egregious.status_code(:not_allowed)
        exception_codes[ActionController::MissingFile].should == Egregious.status_code(:not_found)
        exception_codes[ActionController::RoutingError].should == Egregious.status_code(:bad_request)
        exception_codes[ActionController::UnknownController].should == Egregious.status_code(:bad_request)
        exception_codes[ActionController::UnknownHttpMethod].should == Egregious.status_code(:not_allowed)
        #exception_codes[ActionController::MissingTemplate].should ==  Egregious.status_code(:not_found)
      end
    end

    if defined?(ActiveModel)
      it "should return expected errors for ActiveModel" do
        exception_codes[ActiveModel::MissingAttributeError].should == Egregious.status_code(:bad_request)
      end
    end

    if defined?(ActiveRecord)
      it "should return expected errors for ActiveRecord" do
        exception_codes[ActiveRecord::AttributeAssignmentError].should == Egregious.status_code(:bad_request)
        exception_codes[ActiveRecord::MultiparameterAssignmentErrors].should == Egregious.status_code(:bad_request)
        exception_codes[ActiveRecord::ReadOnlyAssociation].should == Egregious.status_code(:forbidden)
        exception_codes[ActiveRecord::ReadOnlyRecord].should == Egregious.status_code(:forbidden)
        exception_codes[ActiveRecord::RecordInvalid].should == Egregious.status_code(:bad_request)
        exception_codes[ActiveRecord::RecordNotFound].should == Egregious.status_code(:not_found)
        exception_codes[ActiveRecord::UnknownAttributeError].should == Egregious.status_code(:bad_request)
      end
    end

    if defined?(Warden)
      it "should return expected errors for Warden" do
        exception_codes[Warden::NotAuthenticated].should == Egregious.status_code(:unauthorized)
      end
    end

    if defined?(CanCan)
      it "should return expected errors for CanCan" do
        # technically this should be forbidden, but for some reason cancan returns AccessDenied when you are not logged in
        exception_codes[CanCan::AccessDenied].should == Egregious.status_code(:unauthorized)
        exception_codes[CanCan::AuthorizationNotPerformed].should == Egregious.status_code(:unauthorized)
      end
    end

    if defined?(Mongoid)
      it "should return expected errors for Mongoid" do
        exception_codes[Mongoid::Errors::InvalidFind].should == Egregious.status_code(:bad_request)
        exception_codes[Mongoid::Errors::DocumentNotFound].should == Egregious.status_code(:not_found)
        exception_codes[Mongoid::Errors::Validations].should == Egregious.status_code(:unprocessable_entity)
      end

      if Mongoid::VERSION > '3'
        it "should return expected errors for Mongoid 3+" do
          exception_codes[Mongoid::Errors::ReadonlyAttribute].should == Egregious.status_code(:forbidden)
          exception_codes[Mongoid::Errors::UnknownAttribute].should == Egregious.status_code(:bad_request)
        end
      end
    end
  end

  describe "status_code_for_exception" do
    it 'should return 500 for non-mapped exceptions' do
      exception_codes[Exception].should == nil
      status_code_for_exception(Exception.new).should=='500'
    end
    it 'should allow configuration of exception codes' do
      Egregious.exception_codes.merge!({NameError => "999"})
      status_code_for_exception(NameError.new).should=="999"
    end
  end

  describe "exception with http_status method" do
    class PartyLikeIts < StandardError
      def http_status
        1999
      end
    end

    it 'should honor if not in exception code map' do
      exception_codes[PartyLikeIts].should == nil
      status_code_for_exception(PartyLikeIts.new).should=='1999'
    end

    it 'should be overridden by exception code map' do
      exception_codes.merge! ({PartyLikeIts: status_code(:bad_request)})
      exception_codes[PartyLikeIts].should == nil
      status_code_for_exception(PartyLikeIts.new).should==status_code(:bad_request)

    end
  end

  describe "build_html_file_path" do
    it "should build a valid path" do
      Rails.instance_eval do
        def self.root
          __FILE__
        end
      end
      build_html_file_path('500').should == File.join(__FILE__, 'public', '500.html')
    end
  end
end