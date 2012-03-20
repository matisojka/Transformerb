module Transformerb
  class Etl

    attr_accessor :data, :import_attributes, :field_definitions

    def initialize(data, setup = nil)
      @data = data
      @import_attributes = {}
      @field_definitions = {}

      eval setup unless setup.nil?
    end

    def fields(&block)
      trans = FieldTransformer.new(self)
      trans.instance_eval(&block)
    end

  end
end
