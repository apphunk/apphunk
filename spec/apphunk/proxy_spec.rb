require File.dirname(__FILE__) + '/../spec_helper'

describe Apphunk::Proxy do
  describe 'send_message_to_apphunkd_proxy' do
    before(:each) do
      @opts = { :tags => 'test', :token => 'secret' }
      Apphunk::Remote.stub!(:post)
      Apphunk::Proxy.stub!(:process_response).and_return(true)
    end
    
    it 'should prepare the payload' do
      Apphunk::Proxy.should_receive(:prepare_payload).with("My Message", @opts)
      Apphunk::Proxy.send_message_to_apphunkd("My Message", @opts)
    end
    
    it "should return false if options include allowed environments and the current environment isn't included in that list" do
      @opts[:environments] = ['production', 'staging']
      @opts[:environment] = 'development'
      Apphunk::Proxy.send_message_to_apphunkd("My Message", @opts).should be_false
    end
    
    context 'posting' do
      before(:each) do
        @payload = { "prepared" => "payload" }
        Apphunk::Proxy.stub!(:prepare_payload).and_return(@payload)
      end
      
      it 'should post the payload to the local Apphunkd api' do
        Apphunk::Remote.should_receive(:post).with('http://127.0.0.1:8212/api/messages', @payload, anything)
        Apphunk::Proxy.send_message_to_apphunkd("My Message", @opts)
      end
    
      it 'should allow the post to only take 3 seconds to finish' do
        Apphunk::Remote.should_receive(:post).with(anything, anything, 3)
        Apphunk::Proxy.send_message_to_apphunkd("My Message", @opts)
      end
    end
  end
    
  describe 'process_response' do
    before(:each) do
      @result = Apphunk::Remote::Result.new
      @result.response = mock('Response')
      Apphunk::Remote.stub!(:post).and_return(@result)
    end
    
    it 'should return true if the Proxy return 201, created' do
      @result.status = :ok
      @result.response.stub!(:code).and_return("201")
      Apphunk::Proxy.process_response(@result)
    end
    
    it 'should output the failure and return false if the Proxy doesn not return 201' do
      @result.status = :ok
      @result.response.stub!(:code).and_return("404")
      @result.response.stub!(:body).and_return("Not found.")
      Apphunk::Logger.should_receive(:error).with(/Not found/)
      Apphunk::Proxy.process_response(@result)
    end
    
    it 'should output the failure and return false if the connection to the proxy failed' do
      @result.status = :connection_error
      Apphunk::Logger.should_receive(:error).with(/Connection Error/)
      Apphunk::Proxy.process_response(@result)
    end
  end
  
  describe 'prepare_payload' do
    before(:each) do
      @opts = { :token => 'secret', :environment => 'development', :tags => 'test', :trails => { :user => '5' } }
    end
    
    it 'should create an OpenStruct, containing the message and extracted options' do
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
