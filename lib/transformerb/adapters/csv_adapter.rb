module Transformerb
  module Adapters
    class Csv
      attr_accessor :file_obj, :source, :config

      def initialize
        @config = {}
      end

      def parser_config(&block)
        yield Config.new(self)
      end

      def file(file_path)
        @file_obj = File.open(file_path, 'rb')
      end

      def next
        @source = CSV.new(file_obj, @config) if @source.nil?
        next_row = @source.shift

        return nil if next_row.nil?
        next_row.is_a?(Array) ? array_row_to_hash(next_row) : next_row.to_hash
      end

      def array_row_to_hash(row)
        {}.tap do |hash|
          row.each_with_index do |field, index|
            hash[index] = field
          end
        end

      end

      class Config

        def initialize(set)
          @set = set
        end

        def method_missing(method, *args)
          # Convert setter to hash key (symbol)
          method = method.to_s.sub('=', '').to_sym

          @set.config[method] = args[0]
        end
      end

    end
  end
end
