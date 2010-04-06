module Apphunk
  
  # Used to configure the behaviour of Apphunk and its outgoing messages. Each option can be overriden by Apphunk.post's +option+ parameter.
  # If Apphunk is used as part of a Rails application, the configuration should go to +config/initializers/apphunk.rb+.
  #
  # *Note*: The configuration must be set using Apphunk.config as shown in the example below.
  #
  # ==== Example
  #  Apphunk.config do |config|
  #    config.token = "secret_project_token"
  #  end
  #
  module Config
    class << self
      
      # The current environment. Automatically retrieved if Apphunk is running as part of a Rails app.
      #
      # ==== Example
      #  config.environment = 'production'
      #
      attr_accessor :environment
      
      # A list of allowed environments. Apphunk will only send messages if Apphunk::Config.environment is part of these allowed environments.
      # *Note*: This step is skipped if Apphunk::Config.environment is +empty+.
      #
      # ==== Example
      #  config.environments = %w(production staging)
      #
      attr_accessor :environments

      # A list of tags to be send with each message.
      #
      # ==== Example
      #  config.tags = 'each, message, will, get, these, tags'
      #      
      attr_accessor :tags

      # The token as provided by apphunk.com. Used to authenticate a message request.
      #
      # ==== Example
      #  config.token = 'secrect_project_token'
      #      
      attr_accessor :token

      # A list of trails to be send with each message.
      #
      # ==== Example
      #  config.trails = { :product => 'Car', :country => 'Germany' }
      #      
      attr_accessor :trails

    end
  end
end