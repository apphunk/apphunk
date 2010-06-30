require File.dirname(__FILE__) + '/../spec_helper'

describe Apphunk::Proxy do
  describe 'send_message_to_apphunkd_proxy' do
    before(:each) do
      @opts = { :tags => 'test', :token => 'secret' }
      @payload = { :token => 'secret' }
      Apphunk::Proxy.stub!(:process_response).and_return(true)
      Postbox.stub!(:post)
    end
    
    it 'should prepare the payload' do
      Apphunk::Proxy.should_receive(:prepare_payload).with("My Message", @opts).and_return(@payload)
      Apphunk::Proxy.send_message_to_apphunkd("My Message", @opts)
    end
    
    it "should return false if options include allowed environments and the current environment isn't included in that list" do
      @opts[:environments] = ['production', 'staging']
      @opts[:environment] = 'development'
      Apphunk::Proxy.send_message_to_apphunkd("My Message", @opts).should be_false
    end
    
    context 'posting' do
      before(:each) do
        @payload = { :prepared => "payload", :token => "secret" }
        Apphunk::Proxy.stub!(:prepare_payload).and_return(@payload)
      end
      
      it 'should post the payload' do
        Postbox.should_receive(:post).with('http://api.apphunk.com/v1/secret/messages', @payload)
        Apphunk::Proxy.send_message_to_apphunkd("My Message", @opts)
      end
    end
  end
    
  describe 'process_response' do
    before(:each) do
      @result = OpenStruct.new
    end
    
    it 'should return true if the Proxy return 201, created' do
      @result.success = true
      Apphunk::Proxy.process_response(@result).should be_true
    end
    
    it 'should output the failure and return false if the Proxy doesn not return 201' do
      @result.success = false
      Apphunk::Logger.should_receive(:error).with(/not store/)
      Apphunk::Proxy.process_response(@result)
    end
  end
  
  describe 'prepare_payload' do
    before(:each) do
      @opts = { :token => 'secret', :environment => 'development', :tags => 'test', :trails => { :user => '5' } }
    end
    
    it 'should create a Hash, containing the message and extracted options' do
      payload = Apphunk::Proxy.prepare_payload("My Message", @opts)
      payload[:message].should == "My Message"
      payload[:token].should == "secret"
      payload[:environment].should == "development"
      payload[:tags].should == "test"
    end
    
    it 'should render the trails to json' do
      payload = Apphunk::Proxy.prepare_payload("My Message", @opts)
      payload[:trails].should == "{\"user\":\"5\"}"
    end
  end  
end
