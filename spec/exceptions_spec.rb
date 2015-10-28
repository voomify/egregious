require 'spec_helper'
require 'json'
require 'hpricot'
require 'htmlentities'

describe Exception do
  it "should output valid xml on to_xml" do
    doc = Hpricot.XML(Exception.new("Yes").to_xml)
    (doc/:errors).each do |error|
      expect((error/:error).inner_html).to eq('Yes')
      expect((error/:type).inner_html).to eq('Exception')
    end
  end

  it "should output valid xml on to_xml with values to escape" do
    doc = Hpricot.XML(Exception.new('<a title="1<2"/>').to_xml)
    (doc/:errors).each do |error|
      expect(HTMLEntities.new.decode((error/:error).inner_html)).to eq('<a title="1<2"/>')
    end
  end

  it "should output be valid json on to_json" do
    result = JSON.parse(Exception.new("Yes").to_json)
    expect(result['error']).to eq("Yes")
    expect(result['type']).to eq("Exception")
  end

  it "should output be valid json on to_json with quotes" do
    result = JSON.parse(Exception.new('Yes "its good"').to_json)
    expect(result['error']).to eq('Yes "its good"')
  end


  it "should parse module names out" do
    module X
      module Y
        class Z < Exception
        end
      end
    end
    expect(X::Y::Z.new.exception_type).to eq('Z')
  end
end

describe "exception with http_status method" do
  class PartyLikeIts < Egregious::Error
    def initialize(message=nil)
      super(message,1999)
    end
  end
  let(:exception_instance) { PartyLikeIts.new }

  it 'should honor if not in exception code map' do
    expect(Egregious.exception_codes[PartyLikeIts]).to eq(nil)
    expect(Egregious.status_code_for_exception(exception_instance)).to eq(1999)
  end

  it 'should be overridden by exception code map' do
    Egregious.exception_codes.merge!({PartyLikeIts => :bad_request})
    expect(Egregious.exception_codes[PartyLikeIts]).to eq(:bad_request)
    expect(Egregious.status_code_for_exception(exception_instance)).to eq(400)
  end

  it "should throw 500 if nil" do
    expect(Egregious.status_code_for_exception(Egregious::Error.new)).to eq(500)
  end
  it "should throw code for string" do
      expect(Egregious.status_code_for_exception(Egregious::Error.new("hi","2001"))).to eq(2001)
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
      expect(result['error']).to match(/#{error_message}/)
    end

    it "should output xml with a short problem description" do
      doc = Hpricot.XML(exception.to_xml)
      (doc/:errors).each do |error|
        expect(HTMLEntities.new.decode((error/:error).inner_html)).to match(/#{error_message}/)
      end
    end
  end

  describe Mongoid::Errors::Validations do
    let(:model) { TestModel.create }
    let(:exception) { Mongoid::Errors::Validations.new(model) }
    let(:error_message) { model.errors.full_messages.first }

    it "should output json with a short summary" do
      result = JSON.parse(exception.to_json)
      expect(result['error']).to eq(error_message)
    end

    it "should output xml with a short problem description" do
      doc = Hpricot.XML(exception.to_xml)
      (doc/:errors).each do |error|
        expect(HTMLEntities.new.decode((error/:error).inner_html)).to eq(error_message)
      end
    end
  end
end