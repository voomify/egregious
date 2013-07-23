if defined?(Mongoid)
  # Customize the error information Egregious returns for MongoidErrors
  module Mongoid
    module Errors
      class MongoidError
        def to_xml
          "<errors><error>#{HTMLEntities.new.encode(@problem || to_s)}</error><type>#{self.exception_type}</type></errors>"
        end

        def to_json
          "{\"error\":#{ActiveSupport::JSON.encode(@problem || to_s)}, \"type\":\"#{self.exception_type}\"}"
        end
      end
      
      class Validations
        def to_xml
          "<errors><error>#{HTMLEntities.new.encode(self.document.errors.full_messages.join(', ').gsub(/\r/, ' ').gsub(/\n/, ' ').squeeze(' '))}</error><type>#{self.exception_type}</type></errors>"
        end

        def to_json
          "{\"error\":#{ActiveSupport::JSON.encode(self.document.errors.full_messages.join(', ').gsub(/\r/, ' ').gsub(/\n/, ' ').squeeze(' '))}, \"type\":\"#{self.exception_type}\"}"
        end
      end
    end
  end
end