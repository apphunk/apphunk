require 'rubygems'
require 'postbox'

module Apphunk
  
  autoload :Config, 'apphunk/config'
  autoload :Logger, 'apphunk/logger'
  autoload :Proxy,  'apphunk/proxy'
  
  class << self

    # Default options to be used for Apphunk.post. Initialized by Apphunk::Config.
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
    #  Apphunk.post("Yet another hello world")
    #  Apphunk.post("Tag me baby", :tags => 'apphunk, doc, examples', :trails => { :user_id => 5 })
    #  Apphunk.post("I'm on my way to a different project", :token => 'secret_project_access_token')
    #
    def post(message, options = {})
      options = (self.default_options || {}).merge(options)
      Apphunk::Proxy.send_message_to_apphunkd(message, options)
    end
    
    # Send messages with predefined options in a block
    #
    # Yields the Apphunk module which can be used to send messages via Apphunk.post,
    # but temporarily merges the provided +options+ with Apphunk.default_options.
    # Can be used to send a bunch of messages with the same options.
    #
    # * <tt>options</tt> - A hash of options. Merges with Apphunk.default_options
    #
    # For a list of available options see Apphunk::Config.
    #
    # ==== Examples  
    #  Apphunk.post_with_options(:tags => 'hello world') do |apphunk|
    #    apphunk.post("A messages with tags")
    #    apphunk.post("Another messages with the same tags")
    #  end
    #
    def post_with_options(options = {}, &block)
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
      self.default_options ||= {}
      self.default_options[:tags] = Apphunk::Config.tags
      self.default_options[:token] = Apphunk::Config.token
      self.default_options[:trails] = Apphunk::Config.trails
      
      unless Apphunk::Config.environments.nil?
        self.default_options[:environments] = Apphunk::Config.environments
      end
      
      if Apphunk::Config.environment.nil? || Apphunk::Config.environment == ""
        Apphunk::Config.environment = self.default_options[:environment]
      else
        self.default_options[:environment] = Apphunk::Config.environment 
      end
    end
    
    # Init configuration defaults
    def init_defaults #:nodoc:
      if env = rails_environment
        Apphunk.default_options = { 
          :environment => env,
          :environments => %w(production)
        }
      end
    end
    
    # Get the current rails environment if its Rails
    def rails_environment #:nodoc:
      case
      when defined?(RAILS_ENV)
        RAILS_ENV
      when defined?(Rails.env)
        Rails.env
      else
        nil
      end
    end
  end
  
end

Apphunk.init_defaults
