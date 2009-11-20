require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Apphunk" do
  describe 'log' do
    it 'should send the message to the apphunkd-proxy' do
      Apphunk::Proxy.should_receive(:send_message_to_apphunkd).with("My Message", anything)
      Apphunk.log("My Message")
    end
    
    it 'should bypass all options' do
      opts = { :tags => "Hello, World", :trails => { :user => '5', :account => '12' } }
      Apphunk::Proxy.should_receive(:send_message_to_apphunkd).with("My Message", opts)
      Apphunk.log("My Message", opts)
    end
    
    it 'should merge provided options with Apphunk.default_options' do
      Apphunk::Proxy.should_receive(:send_message_to_apphunkd).with("My Message", { :tags => 'Hello', :trails => { :user => '5' }})
      Apphunk.default_options = { :trails => { :user => '5' }}
      Apphunk.log("My Message", :tags => "Hello")
    end
    
    it 'should override Apphunk.default_options with provided options' do
      Apphunk::Proxy.should_receive(:send_message_to_apphunkd).with("My Message", { :tags => 'Bye' })
      Apphunk.default_options = { :tags => 'Hello'}
      Apphunk.log("My Message", :tags => "Bye")
    end
  end
  
  describe 'log_with_options' do
    it 'should yield the Apphunk module back to the block' do
      Apphunk.log_with_options do |apphunk|
        apphunk.should == Apphunk
      end
    end
    
    it 'should set Apphunk.default_options before yielding' do
      Apphunk.log_with_options(:tags => 'hello') do |apphunk|
        apphunk.default_options.should == { :tags => 'hello'}
      end
    end
    
    it 'should merge existing Apphunk.default_options and provided options' do
      Apphunk.default_options = { :token => 'secret' }
      Apphunk.log_with_options(:tags => 'hello', :trails => { :user => '5' }) do |apphunk|
        apphunk.default_options.should == { :tags => 'hello', :trails => { :user => '5'}, :token => 'secret'}
      end      
    end
    
    it 'should init the default_options hash on demand' do
      Apphunk.default_options = nil
      Apphunk.log_with_options(:tags => "hallo") do |apphunk|
        apphunk.should == Apphunk
      end      
    end
    
    it 'should restore old default_options after yielding' do
      Apphunk.default_options = { :token => 'secret' }
      Apphunk.log_with_options(:tags => "hallo") do |apphunk|
        apphunk.should == Apphunk
      end
      Apphunk.default_options.should == { :token => 'secret' }
    end    
  end
end
