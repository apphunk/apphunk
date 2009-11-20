require 'rubygems'

module Apphunk
  
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
    
  end
end