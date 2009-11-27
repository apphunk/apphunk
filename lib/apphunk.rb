require 'rubygems'

module Apphunk
  
  autoload :Config, 'apphunk/config'
  autoload :Logger, 'apphunk/logger'
  autoload :Proxy,  'apphunk/proxy'
  autoload :Remote, 'apphunk/remote'
  
  class << self

    # Default options to be used for Apphunk.log. Initialized by Apphunk::Config.
    attr_accessor :default_options
    
    # Sends a +message+ to your remote inbox at apphunk.com
    # 
    # * <tt>message</tt> - The body of the message
    # * <tt>options</tt> - A hash of options. Merges with Apphunk.default_options
    #
    # For a list of available options see Apphunk::Config.
    #
    # ==== Examples  
    #   
    #  Apphunk.log("Yet another hello world")
    #  Apphunk.log("Tag me baby", :tags => 'apphunk, doc, examples', :trails => { :user_id => 5 })
    #  Apphunk.log("I'm on my way to a different project", :token => 'secret_project_access_token')
    #
    def log(message, options = {})
      options = (self.default_options || {}).merge(options)
      Apphunk::Proxy.send_message_to_apphunkd(message, options)
    end
    
    # Send messages with predefined options in a block
    #
    # Yields the Apphunk module which can be used to send messages via Apphunk.log,
    # but temporarily merges the provided +options+ with Apphunk.default_options.
    # Can be used to send a bunch of messages with the same options.
    #
    # * <tt>options</tt> - A hash of options. Merges with Apphunk.default_options
    #
    # For a list of available options see Apphunk::Config.
    #
    # ==== Examples  
    #  Apphunk.log_with_options(:tags => 'hello world') do |apphunk|
    #    apphunk.log("A messages with tags")
    #    apphunk.log("Another messages with the same tags")
    #  end
    #
    def log_with_options(options = {}, &block)
      preserved_defaults = self.default_options
      self.default_options = (self.default_options || {}).merge(options)
      yield self
      self.default_options = preserved_defaults
    end
    
    # Set runtime configuration options
    #
    # Yields Apphunk::Config which can be used to set configuration options in one place.
    # See Apphunk::Config for a list of available options. These options will be available in Apphunk.default_options.
    #
    # ==== Examples
    #
    #  Apphunk.config do |config|
    #    config.token = "secret_project_token"
    #    config.environments = %w(staging production)
    #  end
    #
    def config(&block)
      yield Apphunk::Config
      self.default_options[:tags] = Apphunk::Config.tags
      self.default_options[:token] = Apphunk::Config.token
      self.default_options[:trails] = Apphunk::Config.trails
      self.default_options[:environments] = Apphunk::Config.environments
      
      if Apphunk::Config.environment.blank?
        Apphunk::Config.environment = self.default_options[:environment]
      else
        self.default_options[:environment] = Apphunk::Config.environment 
      end
    end
    
  end
end