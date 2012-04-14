module Transformerb
  class Transformer

    attr_reader :mapping

    def initialize
      @mapping = {}
    end

    def define(*args, &block)
      if block_given? # define :first_name, :from => 'First' {}
        options = args.extract_options!
        @mapping[args.first] = [options[:from], block]
      else
        if args.first.is_a?(Symbol) # define :id
          @mapping[args.first] = args.first.to_s
        elsif args.first.is_a?(Hash) # define :last_name => 'Last'
          @mapping.merge!(args.first)
        end
      end
    end

  end
end
