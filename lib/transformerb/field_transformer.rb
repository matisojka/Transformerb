module Transformerb
  class FieldTransformer

    def initialize(set)
      @set = set
    end

    def define(definition_hash)
      length = definition_hash.delete(:length)

      field_name = definition_hash.keys.first
      field_type = definition_hash.values.first

      @set.field_definitions[field_name] = {
        :type       => field_type,
        :length     => length
      }
    end

    def take(source_field_names, options = {}, &block)
      return shortcut_take(source_field_names, &block) if source_field_names.is_a?(Hash)

      source_value = join_fields(Array(source_field_names), options)

      destination_value = block_given? ? yield(source_value) : source_value
      destination_name = options[:as].nil? ? normalize_attribute_name(source_field_names) : options[:as]

      destination_value = apply_definition(destination_name, destination_value)

      @set.import_attributes[destination_name] = destination_value
      {:attribute => destination_name, :value => destination_value}
    end

    def shortcut_take(field_map, &block)
      destination_name = field_map.values.first
      source_field = field_map.keys.first
      destination_value = join_fields(Array(source_field))

      destination_value = apply_definition(destination_name, destination_value)

      @set.import_attributes[destination_name] = destination_value
      {:attribute => destination_name, :value => destination_value}
    end

    def take_and_map(source_field_names, mapping = {}, options = {})
      taken_attribute = take(source_field_names, options)

      attribute_name = taken_attribute[:attribute]
      attribute_value = taken_attribute[:value]
      new_value = options[:default] || ''

      mapping.each do |destination, source|
        regexp_source = convert_to_regexp(source)

        if regexp_source =~ attribute_value
          new_value = destination
          break
        end
      end

      new_value = apply_definition(attribute_name, new_value)
      @set.import_attributes[attribute_name] = new_value
      {:attribute => attribute_name, :value => new_value}
    end

    def cast(attribute, options = {})
      source_value = @set.import_attributes[attribute]
      type = options[:to]

      @set.import_attributes[attribute] = cast_helper(type, source_value)
    end

    def edit(attribute_name, &block)
      new_value = yield(@set.import_attributes[attribute_name])

      new_value = apply_definition(attribute_name, new_value)

      @set.import_attributes[attribute_name] = new_value
      {:attribute => attribute_name, :value => new_value}
    end

    protected

    def join_fields(fields, options = {})
      join_element = options[:join_with] || ''

      fields.map { |field| @set.data[field] }.join(join_element)
    end

    def normalize_attribute_name(name)
      # Regexp: convert whitespaces to one single underscore and remove any non-word characters
      name.downcase.gsub(/\s+/, '_').gsub(/\W/, '').to_sym
    end

    def cast_helper(type, value)
      case type
      when :integer then value.to_i
        when :datetime then DateTime.parse(value)
        else value.to_s
      end
    end

    def apply_definition(field_name, field_value)
      return field_value if @set.field_definitions[field_name].nil?

      field_type = @set.field_definitions[field_name][:type]
      field_length = @set.field_definitions[field_name][:length] || -1 # -1 means last element in range

      field_value = cast_helper(field_type, field_value)
      field_value[0...field_length] if field_value.is_a?(String)
    end

    def convert_to_regexp(source)
      if source.is_a?(Array)
        array_to_regexp(source)
      elsif source.is_a?(Regexp)
        source
      else
        string_to_regexp(source)
      end
    end

    def string_to_regexp(string)
      Regexp.new("^#{string}$")
    end

    def array_to_regexp(array)
      regexp_array = array.map { |elem| string_to_regexp(elem) }

      Regexp.union(regexp_array)
    end

  end
end
