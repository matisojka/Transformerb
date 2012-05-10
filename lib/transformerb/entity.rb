module Transformerb
  class Entity
    include ActiveModel::Validations

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
          value = field_eval(attribute_name, raw_value, &data_key.last)
        end

        send("#{attribute_name}=", value)
        @attributes << attribute_name
      end
    end

    def field_eval(name, raw_value, &block)
      Field.new(self, name, raw_value, &block).value
    end

    class Field
      include ActiveModel::Validations

      attr_accessor :value

      def initialize(entity, name, raw_value, &block)
        @entity       = entity
        @name         = name
        @value        = raw_value

        self.instance_eval(&block)
      end

      def convert
        @value = yield @value
      end

      def validates(*args)
        name = @name
        Entity.class_eval { validates(name, *args) }
      end

    end
  end
end
