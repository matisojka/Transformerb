module Transformerb
  class Etl

    attr_accessor :data, :import_attributes, :field_definitions
    attr_accessor :extractor, :loader, :transformer, :fields

    def initialize
      @import_attributes = {}
      @field_definitions = {}
    end

    def run(file)
      etl_setup = file.is_a?(String) ? file : File.open(file).read

      instance_eval etl_setup

      while(@data = @extractor.next) do
        @transformer.instance_eval(&@fields)
        @loader.write(@import_attributes)
      end
    end

    def source(adapter, &block)
      adapter_class = "transformerb/adapters/#{adapter.to_s}".camelize.constantize
      @extractor = adapter_class.new.extractor
      @extractor.instance_eval(&block)
    end

    def fields(&block)
      @transformer ||= FieldTransformer.new(self)
      @fields = block
    end

    def load(adapter, &block)
      adapter_class = "transformerb/adapters/#{adapter.to_s}".camelize.constantize
      @loader = adapter_class.new.loader
      @loader.instance_eval(&block)
    end

  end
end
