module Transformerb
  class Entity

    def initialize(raw_data, mapping)
      @raw_data = raw_data
      @mapping = mapping

      @attributes = []
      create_attributes
    end

    private

    def create_attributes
      @mapping.each do |attribute_name, data_key|
        if data_key.is_a?(String) # :first_name => 'First'
          value = @raw_data[data_key]
        else # :first_name => ['First', Proc]
          raw_value = @raw_data[data_key.first]
          value = field_eval(raw_value, &data_key.last)
        end

        send("#{attribute_name}=", value)
        @attributes << attribute_name
      end
    end

    def field_eval(raw_value, &block)
      field = Field.new(raw_value)
      field.instance_eval(&block)
    end

    class Field

      def initialize(attribute)
        @attribute = attribute
      end

      def convert
        yield @attribute
      end
    end
  end
end
