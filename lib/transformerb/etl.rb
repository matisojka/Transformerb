module Transformerb
  class Etl

    attr_accessor :data, :import_attributes, :field_definitions, :extractor

    def initialize(data, setup = nil)
      @data = data
      @import_attributes = {}
      @field_definitions = {}

      eval setup unless setup.nil?
    end

    def source(adapter, &block)
      adapter_class = "transformerb/adapters/#{adapter.to_s}".camelize.constantize
      @extractor = adapter_class.new
      @extractor.instance_eval(&block)
    end

    def fields(&block)
      trans = FieldTransformer.new(self)
      trans.instance_eval(&block)
    end

  end
end
