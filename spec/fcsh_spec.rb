require 'spec_helper'
require 'fcsh'

describe Fcsh do
  before(:each) do
    @fcsh = Fcsh.new
  end
  
  
  it "uses the constant location if that's set" do
    Fcsh.should_receive(:location=).with("test").once
    Fcsh.location = 'test'
  end
  
  
  it "should compile a basic file" do
    lambda {@fcsh.mxmlc("test.as") }.should raise_error
  end
  
  it "should compile and after that continue" do
    target_id = @fcsh.mxmlc("fixtures/main.mxml")
    target_id.should == 1
    @fcsh.compile(target_id)
  end
  
  
  
  
  
end