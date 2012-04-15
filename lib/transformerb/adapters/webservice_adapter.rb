module Transformerb
  module Adapters
    class Webservice

      def initialize(uri)
        @uri = uri
        @config = { :method => :get, :type => :json }
      end

      def config(hash)
        @config.merge!(hash)
      end

      def extract
        response = HTTParty.send(@config[:method], @uri)

        [].tap do |content|
          response.each do |item|
            content << item
          end
        end

      end

    end
  end
end
