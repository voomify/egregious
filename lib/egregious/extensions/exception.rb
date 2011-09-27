#
# We are opening up Exception and adding to_xml and to_json.
#
class Exception

  def exception_type
    self.class.to_s ? self.class.to_s.split("::").last : 'None'
  end

  def to_xml
    "<errors><error>#{self.message}</error><type>#{self.exception_type}</type></errors>"
  end

  def to_json
    "{\"error\":\"#{self.message.gsub(/\r/, ' ').gsub(/\n/, ' ').squeeze(' ')}\", \"type\":\"#{self.exception_type}\"}"
  end
end