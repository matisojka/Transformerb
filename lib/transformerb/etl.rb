module Transformerb
  class Etl

    attr_accessor :data, :import_attributes, :field_definitions

    def initialize(data, setup = nil)
      @data = data
      @import_attributes = {}
      @field_definitions = {}

      eval setup unless setup.nil?
    end

    def source(adapter, &block)
      adapter_class = "Transformerb::Adapters::#{adapter.camelize.constantize}"
      adapter = adapter_class.new
      adapter.instance_eval(&block)
    end

    def fields(&block)
      trans = FieldTransformer.new(self)
      trans.instance_eval(&block)
    end

  end
end
