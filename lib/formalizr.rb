require "active_support/inflector"
require "formalizr/version"
require "formalizr/validators"
require "pry"

module Formalizr
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
        Validators::Validator.load(validation)
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
  end

  class TextInputSchema < InputSchema
  end

  class NumberInputSchema < InputSchema
  end

  class ParagraphInputSchema < InputSchema
  end

  class MultiCheckInputSchema < InputSchema
  end

  class RadioInputSchema < InputSchema
  end

  class SelectInputSchema < InputSchema
  end

  class TableInputSchema < InputSchema
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
  end

  class TableCellInputSchema < InputSchema
  end

  class TableTextInput < TableCellInputSchema
  end

  class TableNumberInputSchema < TableCellInputSchema
  end

  class TableSelectInput < TableCellInputSchema
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
  end
end
