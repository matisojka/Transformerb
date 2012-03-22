module Transformerb
  class Etl

    attr_accessor :data, :import_attributes, :field_definitions
    attr_accessor :extractor, :loader, :transformer, :fields

    def initialize(data, setup = nil)
      @data = data
      @import_attributes = {}
      @field_definitions = {}

      eval setup unless setup.nil?
    end

    def run
      while row = @extractor.next do
        @data = row
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
      @transformer = FieldTransformer.new(self)
      @fields = block
    end

    def load(adapter, &block)
      adapter_class = "transformerb/adapters/#{adapter.to_s}".camelize.constantize
      @loader = adapter_class.new.loader
      @loader.instance_eval(&block)
    end

  end
end
