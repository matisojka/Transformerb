module Transformerb
  module Adapters
    class Memory

      def initialize(raw_data, mapping)
        @raw_data = raw_data
        @mapping = mapping
      end

      def load
        @mapping.each do |new_key, _|
          Entity.class_eval { attr_accessor new_key }
        end

        @raw_data.map do |data_row|
          Entity.new(data_row, @mapping)
        end
      end

    end
  end
end
