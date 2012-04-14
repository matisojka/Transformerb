module Transformerb
  module Adapters
    class Csv

      def initialize(source)
        @config = { :headers => :first_row }
        @source = File.open(source, 'rb').read
      end

      def config(hash)
        @config.merge!(hash)
      end

      def extract
        [].tap do |csv|
          CSV.parse(@source, @config) do |row|
            csv << row.to_hash
          end
        end
      end

      def self.load(destination, raw_data, mapping)
        keys = mapping.keys
        CSV.open(destination, 'w') do |csv|
          csv << keys
          raw_data.each do |data_row|
            entity = Entity.new(data_row, mapping)
            csv << keys.map do |key|
              entity.send(key)
            end
          end
        end
      end

    end
  end
end
