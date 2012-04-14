module Transformerb
  class Etl

    def self.transform(&block)
      transformation = Etl.new

      transformation.instance_eval(&block)
      transformation.loader :memory
    end

    def extract(adapter, source, &block)
      adapter_class = "transformerb/adapters/#{adapter.to_s}".camelize.constantize
      adapter = adapter_class.new(source)
      adapter.instance_eval(&block)

      @raw_data = adapter.extract
    end

    def transform(&block)
      @transformer = Transformer.new
      @transformer.instance_eval(&block)

      @mapping = @transformer.mapping
    end

    def loader(adapter, &block)
      adapter_class = "transformerb/adapters/#{adapter.to_s}".camelize.constantize
      adapter = adapter_class.new(@raw_data, @mapping)

      adapter.load
    end

  end
end
