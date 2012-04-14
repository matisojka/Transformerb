module Transformerb
  class Etl

    def self.transform(file_path = nil, &block)
      transformation = Etl.new

      if file_path.nil?
        transformation.instance_eval(&block)
      else
        file = File.open(file_path, 'rb').read
        transformation.instance_eval(file)
      end

      transformation.loader :memory
    end

    def extract(adapter, source, &block)
      adapter_class = "transformerb/adapters/#{adapter.to_s}".camelize.constantize
      adapter = adapter_class.new(source)

      if block_given?
        adapter.instance_eval(&block)
      end

      @raw_data = adapter.extract
    end

    def transform(&block)
      @transformer = Transformer.new
      @transformer.instance_eval(&block)

      @mapping = @transformer.mapping
    end

    def loader(adapter, destination = nil, &block)
      adapter_class = "transformerb/adapters/#{adapter.to_s}".camelize.constantize
      adapter_class.load(destination, @raw_data, @mapping)
    end

  end
end
