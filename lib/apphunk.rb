require 'rubygems'

module Apphunk
  
  autoload :Config, 'apphunk/config'
  autoload :Logger, 'apphunk/logger'
  autoload :Proxy,  'apphunk/proxy'
  autoload :Remote, 'apphunk/remote'
  
  class << self

    attr_accessor :default_options
    
    def log(message, options = {})
      options = (self.default_options || {}).merge(options)
      Apphunk::Proxy.send_message_to_apphunkd(message, options)
    end
    
    def log_with_options(options = {}, &block)
      preserved_defaults = self.default_options
      self.default_options = (self.default_options || {}).merge(options)
      yield self
      self.default_options = preserved_defaults
    end
    
    def config(&block)
      yield Apphunk::Config
      self.default_options[:token] = Apphunk::Config.token
      self.default_options[:environments] = Apphunk::Config.environments
      if Apphunk::Config.environment.blank?
        Apphunk::Config.environment = self.default_options[:environment]
      else
        self.default_options[:environment] = Apphunk::Config.environment 
      end
    end
    
  end
end