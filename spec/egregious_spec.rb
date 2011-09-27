require 'spec_helper'

def rescue_from(exception, options)
end

include Egregious

describe Egregious do
  describe 'clean_backtrace ' do
    it "should return nil" do
      clean_backtrace(Exception.new).should == nil
    end

    it "should return a stack trace" do
      begin
        raise Exception.new
      rescue Exception=>exception
        clean_backtrace(exception).size.should be > 0
      end
    end

    it "should remove the beginning of the backtrace" do
      begin
        raise Exception.new
      rescue Exception=>exception
        class Rails
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
      exception_codes[SecurityError].should ==  Egregious.status_code(:forbidden)
    end

    if defined?(ActionController)
      it "should return expected errors for ActionController" do
         exception_codes[AbstractController::ActionNotFound].should ==  Egregious.status_code(:forbidden)
         exception_codes[AbstractController::ActionNotFound].should ==  Egregious.status_code(:bad_request)
         exception_codes[ActionController::InvalidAuthenticityToken].should ==  Egregious.status_code(:bad_request)
         exception_codes[ActionController::MethodNotAllowed].should ==  Egregious.status_code(:not_allowed)
         exception_codes[ActionController::MissingFile].should ==  Egregious.status_code(:not_found)
         exception_codes[ActionController::RoutingError].should ==  Egregious.status_code(:bad_request)
         exception_codes[ActionController::UnknownController].should ==  Egregious.status_code(:bad_request)
         exception_codes[ActionController::UnknownHttpMethod].should ==  Egregious.status_code(:not_allowed)
         exception_codes[ActionController::MissingTemplate].should ==  Egregious.status_code(:not_found)
      end
    end

    if defined?(ActiveModel)
      it "should return expected errors for ActiveModel" do
        exception_codes[ActiveModel::MissingAttributeError].should ==  Egregious.status_code(:bad_request)
      end
    end

    if defined?(ActiveRecord)
      it "should return expected errors for ActiveRecord" do
         exception_codes[ActiveRecord::AttributeAssignmentError].should ==  Egregious.status_code(:bad_request)
         exception_codes[ActiveRecord::HasAndBelongsToManyAssociationForeignKeyNeeded].should ==  Egregious.status_code(:bad_request)
         exception_codes[ActiveRecord::MultiparameterAssignmentErrors].should ==  Egregious.status_code(:bad_request)
         exception_codes[ActiveRecord::ReadOnlyAssociation].should ==  Egregious.status_code(:forbidden)
         exception_codes[ActiveRecord::ReadOnlyRecord].should ==  Egregious.status_code(:forbidden)
         exception_codes[ActiveRecord::RecordInvalid].should ==  Egregious.status_code(:bad_request)
         exception_codes[ActiveRecord::RecordNotFound].should ==  Egregious.status_code(:not_found)
         exception_codes[ActiveRecord::UnknownAttributeError].should ==  Egregious.status_code(:bad_request)
      end
    end

    if defined?(Warden)
      it "should return expected errors for Warden" do
        exception_codes[Warden::NotAuthenticated].should ==  Egregious.status_code(:unauthorized)
      end
    end

    if defined?(CanCan)
      it "should return expected errors for CanCan" do
        # technically this should be forbidden, but for some reason cancan returns AccessDenied when you are not logged in
        exception_codes[CanCan::AccessDenied].should ==  Egregious.status_code(:unauthorized)
        exception_codes[CanCan::AuthorizationNotPerformed].should ==  Egregious.status_code(:unauthorized)
      end
    end
  end

  describe "status_code_for_exception" do
    it 'should return 500 for non-mapped exceptions'do
      exception_codes[Exception].should == nil
      status_code_for_exception(Exception.new).should=='500'
    end
    it 'should allow configuration of exception codes' do
      Egregious.exception_codes.merge!({NameError => "999"})
      status_code_for_exception(NameError.new).should=="999"
    end
    end
end