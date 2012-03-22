module Transformerb
  module Adapters
    class Csv
      attr_accessor :extractor, :loader

      def initialize
        @extractor = Extractor.new
        @loader = Loader.new
      end

      def next
        @extractor.next
      end

      def write(content)
        @loader.write(content)
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

      class Extractor
        attr_accessor :config, :source_file

        def initialize
          @config = {}
        end

        def file(file_path)
          @source_file = File.open(file_path, 'rb')
        end

        def parser_config(&block)
          yield Config.new(self)
        end

        def next
          @source ||= CSV.new(@source_file, @config)
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
      end

      class Loader
        attr_accessor :config, :destination_file_path

        def initialize
          @config = {}
        end

        def file(file_path)
          @destination_file_path = file_path
        end

        def parser_config(&block)
          yield Config.new(self)
        end

        def write(content)
          row = CSV::Row.new(content.keys, content.values, :header_row => true)
          CSV.open(@destination_file_path, 'a') do |csv|
            csv << row
          end
        end

      end

    end
  end
end
