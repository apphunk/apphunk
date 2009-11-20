require 'net/http'
require 'timeout'
require 'uri'

module Apphunk
  module Remote
    
    autoload :Result, 'apphunk/remote/result'
    
    class << self
      
      def post(url, payload = {}, post_timeout = 30)
        begin
          Timeout.timeout(post_timeout) do
            uri = URI.parse(url)
            result = Remote::Result.new(:response => Net::HTTP.post_form(uri, payload))
            result.status = :ok
            return result
          end
        rescue SocketError, Errno::ECONNREFUSED
          Remote::Result.new(:status => :connection_error)
        rescue Timeout::Error
          Remote::Result.new(:status => :timeout)
        end
      end
      
    end
  end
end