require "active_support/inflector"
require "formalizr/version"
require "formalizr/validators"
require "formalizr/querier"
require "pry"

module Formalizr
  class InvalidInput < StandardError ; end
  class InvalidSchema < StandardError ; end

  class InputSchema
    attr_reader :name, :type, :title, :note

    def initialize(definition)
      @name = definition['name']
      @type = definition['type']
      @title = definition['title']
      @note = definition['note']
      @default_value = definition['defaultValue'] || ''
      # FIXME:
      @validators = (definition['validators'] || []).map do |validation|
        load_validation(validation)
      end
    end

    def self.load(definition)
      type = definition['type'].capitalize
      schema = Formalizr.const_get("#{type}InputSchema")
      schema.new(definition)
    end

    def validate(input)
      input ||= @default_value
      validities = @validators.map do |validator|
        validator.validate(input)
      end
      [name, { 'validities' => validities } ]
    end

    def normalize(input)
      [name, input || @default_value]
    end
  end

  class TextInputSchema < InputSchema
    include StringValidators
  end

  class NumberInputSchema < InputSchema
    include IntegerValidators

    def initialize(definition)
      super(definition)

      has_number_validator = @validators.any? do |validator|
        validator.is_a? Number
      end

      unless has_number_validator
        raise InvalidSchema, "number type field requires number validator"
      end
    end

    def normalize(input)
      name, value = super(input)
      value = Integer(value) if value.length > 0
      [name, value]
    end
  end

  class ParagraphInputSchema < InputSchema
    include StringValidators
  end

  class MultiCheckInputSchema < InputSchema
    include SetValidators
  end

  class RadioInputSchema < InputSchema
    include StringValidators
  end

  class SelectInputSchema < InputSchema
    include Validators
  end

  class TableInputSchema < InputSchema
    include TableValidators

    def initialize(definition)
      super(definition)
      @default_value = definition['defaultValue'] || []
      @columns = definition['columns'].map{ |column| InputSchema.load(column) }
    end

    def validate(input)
      result = super(input)
      input ||= @default_value
      result[1]['children'] = input.map do |row|
        @columns.map{ |col| col.validate(row[col.name]) }.to_h
      end
      result
    end

    def normalize(input)
      key, shallow_normalized = super(input)
      deep_normalized = shallow_normalized.map do |child|
        @columns.map{ |col| col.normalize(child[col.name]) }.to_h
      end

      [key, deep_normalized]
    end
  end

  class TableCellInputSchema < InputSchema
  end

  class TableTextInput < TableCellInputSchema
    include StringValidators
  end

  class TableNumberInputSchema < TableCellInputSchema
    include IntegerValidators
  end

  class TableSelectInput < TableCellInputSchema
    include Validators
  end

  class FormSchema
    def initialize(form_schema)
      @input_schemata = form_schema.map do |input_schema|
        InputSchema.load(input_schema)
      end
    end

    def validate(input)
      @input_schemata.map{ |schema|
        schema.validate(input[schema.name])
      }.to_h
    end

    def valid?(input)
      validities = validate(input)
      _valid?(validities)
    end

    def normalize(input)
      raise InvalidInput unless valid?(input)
      normalized_fields = @input_schemata.map do |schema|
        schema.normalize(input[schema.name])
      end
      normalized_fields.to_h
    end

    private
    def _valid?(validities)
      return true if validities.nil?
      validities.all? do |key, field|
        local_validity = field['validities'].all?{ |rule| rule['validity'] }
        children_validity = field['children'].nil?
        children_validity ||= field['children'].all?{ |child| _valid?(child) }
        local_validity && children_validity
      end
    end
  end
end
