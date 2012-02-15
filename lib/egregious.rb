require "egregious/version"
require "egregious/extensions/exception"
require 'rack'


module Egregious

  # use these exception to control the code you are throwing from you code
  # all http statuses have an exception defined for them
  Rack::Utils::HTTP_STATUS_CODES.each do |key, value|
    class_eval "class #{value.gsub(/\s|-/,'')} < StandardError; end"
  end

  def self.status_code(status)
    if status.is_a?(Symbol)
      key = status.to_s.split("_").map {|e| e.capitalize}.join(" ")
      Rack::Utils::HTTP_STATUS_CODES.invert[key] || 500
    else
      status.to_i
    end
  end

  def status_code(status)
    Egregious.status_code(status)
  end


  # internal method that loads the exception codes
  def self._load_exception_codes

    # by default if there is not mapping they map to 500/internal server error
    exception_codes = {
        SecurityError=>status_code(:forbidden)
    }
    # all status codes have a exception class defined
    Rack::Utils::HTTP_STATUS_CODES.each do |key, value|
      exception_codes.merge!(eval("Egregious::#{value.gsub(/\s|-/,'')}")=>value.downcase.gsub(/\s|-/, '_').to_sym)
    end

    if defined?(ActionController)
      exception_codes.merge!({
                               AbstractController::ActionNotFound=>status_code(:bad_request),
                               ActionController::InvalidAuthenticityToken=>status_code(:bad_request),
                               ActionController::MethodNotAllowed=>status_code(:not_allowed),
                               ActionController::MissingFile=>status_code(:not_found),
                               ActionController::RoutingError=>status_code(:bad_request),
                               ActionController::UnknownController=>status_code(:bad_request),
                               ActionController::UnknownHttpMethod=>status_code(:not_allowed)
                               #ActionController::MissingTemplate=>status_code(:not_found)
                             })
    end

    if defined?(ActiveModel)
      exception_codes.merge!({
                                 ActiveModel::MissingAttributeError=>status_code(:bad_request)})
    end

    if defined?(ActiveRecord)
      exception_codes.merge!({
                               ActiveRecord::AttributeAssignmentError=>status_code(:bad_request),
                               ActiveRecord::HasAndBelongsToManyAssociationForeignKeyNeeded=>status_code(:bad_request),
                               ActiveRecord::MultiparameterAssignmentErrors=>status_code(:bad_request),
                               ActiveRecord::ReadOnlyAssociation=>status_code(:forbidden),
                               ActiveRecord::ReadOnlyRecord=>status_code(:forbidden),
                               ActiveRecord::RecordInvalid=>status_code(:bad_request),
                               ActiveRecord::RecordNotFound=>status_code(:not_found),
                               ActiveRecord::UnknownAttributeError=>status_code(:bad_request)
                             })
    end

    if defined?(Warden)
      exception_codes.merge!({
                                 Warden::NotAuthenticated=>status_code(:unauthorized),
                             })
    end

    if defined?(CanCan)
      # technically this should be forbidden, but for some reason cancan returns AccessDenied when you are not logged in
      exception_codes.merge!({CanCan::AccessDenied=>status_code(:unauthorized)})
      exception_codes.merge!({CanCan::AuthorizationNotPerformed => status_code(:unauthorized)})
    end

    @@exception_codes = exception_codes
  end

  @@exception_codes = self._load_exception_codes
  @@root = defined?(Rail) ? Rails.root : nil

  # exposes the root of the app
  def self.root
    @@root
  end

  # set the root directory and stack traces will be cleaned up
  def self.root=(root)
    @@root=root
  end

  # a little helper to help us clean up the backtrace
  # if root is defined it removes that, for rails it takes care of that
  def clean_backtrace(exception)
    if backtrace = exception.backtrace
      if Egregious.root
        backtrace.map { |line| line.sub Egregious.root, '' }
      else
        backtrace
      end
    end
  end

  # this method exposes the @@exception_codes class variable
  # allowing someone to re-configure the mapping. For example in a rails initializer:
  # Egregious.exception_codes = {NameError => "503"}   or
  # If you want the default mapping and then want to modify it you should call the following:
  # Egregious.exception_codes.merge!({MyCustomException=>"500"})
  def self.exception_codes
    @@exception_codes
  end

  # this method exposes the @@exception_codes class variable
  # allowing someone to re-configure the mapping. For example in a rails initializer:
  # Egregious.exception_codes = {NameError => "503"}   or
  # If you want the default mapping and then want to modify it you should call the following:
  # Egregious.exception_codes.merge!({MyCustomException=>"500"})
  def self.exception_codes=(exception_codes)
    @@exception_codes=exception_codes
  end

  # this method will auto load the exception codes if they are not set
  # by an external configuration call to self.exception_code already
  # it is called by the status_code_for_exception method
  def exception_codes
    return Egregious.exception_codes
  end

  # this method will lookup the exception code for a given exception class
  # if the exception is not in our map then it will return 500
  def status_code_for_exception(exception)
    self.exception_codes[exception.class] ? self.exception_codes[exception.class] : '500'
  end

  # this is the method that handles all the exceptions we have mapped
  def egregious_exception_handler(exception)
    egregious_flash(exception)
    egregious_log(exception)
    egregious_respond_to(exception)
  end

  # override this if you want your flash to behave differently
  def egregious_flash(exception)
    flash.now[:alert] = exception.message
  end

  # override this if you want your logging to behave differently
  def egregious_log(exception)
    logger.fatal(
        "\n\n" + exception.class.to_s + ' (' + exception.message.to_s + '):\n    ' +
            clean_backtrace(exception).join("\n    ") +
            "\n\n")
    HoptoadNotifier.notify(exception) if defined?(HoptoadNotifier)
  end

  # override this if you want to change your respond_to behavior
  def egregious_respond_to(exception)
    respond_to do |format|
      status = status_code_for_exception(exception)
      format.xml { render :xml=> exception.to_xml, :status => status }
      format.json { render :json=> exception.to_json, :status => status }
      # render the html page for the status we are returning it exists...if not then render the 500.html page.
      format.html { render :file => File.exists?(build_html_file_path(status)) ?
                                      build_html_file_path(status) : build_html_file_path('500'),
                           :status => status }
    end
  end

  def build_html_file_path(status)
    File.join(Rails.root, 'public', "#{status_code(status)}.html")
  end

  def self.included(base)
    base.class_eval do
      rescue_from 'Exception' , :with => :egregious_exception_handler
    end
  end
end
