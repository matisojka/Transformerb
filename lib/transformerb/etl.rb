module Transformerb
  class Etl

    attr_accessor :data, :import_attributes, :field_definitions, :extractor, :loader

    def initialize(data, setup = nil)
      @data = data
      @import_attributes = {}
      @field_definitions = {}

      eval setup unless setup.nil?
    end

    def source(adapter, &block)
      adapter_class = "transformerb/adapters/#{adapter.to_s}".camelize.constantize
      @extractor = adapter_class.new.extractor
      @extractor.instance_eval(&block)
    end

    def fields(&block)
      trans = FieldTransformer.new(self)
      trans.instance_eval(&block)
    end

    def load(adapter, &block)
      adapter_class = "transformerb/adapters/#{adapter.to_s}".camelize.constantize
      @loader = adapter_class.new.loader
      @loader.instance_eval(&block)
    end

  end
end
