if defined?(Mongoid)
  # Customize the error information Egregious returns for MongoidErrors

  Mongoid::Errors::MongoidError.class_eval do
    def to_xml
      "<errors><error>#{HTMLEntities.new.encode(self.document.errors.full_messages.join(', ').gsub)}</error><type>#{self.exception_type}</type></errors>"
    end

    def to_json
      "{\"error\":#{ActiveSupport::JSON.encode(self.document.errors.full_messages.join(', ').gsub(/\r/, ' ').gsub(/\n/, ' ').squeeze(' '))}, \"type\":\"#{self.exception_type}\"}"
    end
  end
end