require 'spec_helper'
require 'json'
require 'hpricot'
require 'htmlentities'

describe Exception do
  it "should output valid xml on to_xml" do
    doc = Hpricot.XML(Exception.new("Yes").to_xml)
    (doc/:errors).each do |error|
       (error/:error).inner_html.should=='Yes'
      (error/:type).inner_html.should=='Exception'
    end
  end

  it "should output valid xml on to_xml with values to escape" do
    doc = Hpricot.XML(Exception.new('<a title="1<2"/>').to_xml)
    (doc/:errors).each do |error|
       HTMLEntities.new.decode((error/:error).inner_html).should=='<a title="1<2"/>'
    end
  end

  it "should output be valid json on to_json" do
    result = JSON.parse(Exception.new("Yes").to_json)
    result['error'].should == "Yes"
    result['type'].should == "Exception"
  end

  it "should output be valid json on to_json with quotes" do
      result = JSON.parse(Exception.new('Yes "its good"').to_json)
      result['error'].should == 'Yes "its good"'
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

if defined?(Mongoid)
  class TestModel
    include Mongoid::Document
    
    field :foo
    validates_presence_of :foo
  end

  
  describe Mongoid::Errors::MongoidError do
    let(:exception) { Mongoid::Errors::InvalidFind.new }
    let(:error_message) { "Calling Document.find with nil is invalid." }
    
    it "should output json with a short problem description" do
      result = JSON.parse(exception.to_json)
      result['error'].should == error_message
    end
    
    it "should output xml with a short problem description" do
      doc = Hpricot.XML(exception.to_xml)
      (doc/:errors).each do |error|
         HTMLEntities.new.decode((error/:error).inner_html).should == error_message
      end
    end
  end
  
  describe Mongoid::Errors::Validations do
    let(:model) { TestModel.create }
    let(:exception) { Mongoid::Errors::Validations.new(model) }
    let(:error_message) { model.errors.full_messages.first }
    
    it "should output json with a short summary" do
      result = JSON.parse(exception.to_json)
      result['error'].should == error_message
    end
    
    it "should output xml with a short problem description" do
      doc = Hpricot.XML(exception.to_xml)
      (doc/:errors).each do |error|
         HTMLEntities.new.decode((error/:error).inner_html).should == error_message
      end
    end
  end
end