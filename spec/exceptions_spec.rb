require 'spec_helper'
require 'json'
require 'hpricot'

describe Exception do
  it "should output valid xml on to_xml" do
    doc = Hpricot.XML(Exception.new("Yes").to_xml)
    (doc/:errors).each do |error|
       (error/:error).inner_html.should=='Yes'
      (error/:type).inner_html.should=='Exception'
    end
  end

  it "should output be valid json on to_json" do
    result = JSON.parse(Exception.new("Yes").to_json)
    result['error'].should == "Yes"
    result['type'].should == "Exception"
  end

  it "should parse module names out" do
    module X
      module Y
        class Z < Exception
        end
      end
    end
    X::Y::Z.new.exception_type.should == 'Z'
  end
end