module Transformerb
  module Adapters
    class Csv

      def initialize(source)
        @source = File.open(source, 'rb').read
      end

      def config(hash)
        @config = hash
      end

      def extract
        [].tap do |csv|
          CSV.parse(@source, @config) do |row|
            csv << row.to_hash
          end
        end
      end

    end
  end
end
