module Formalizr
  module Validators
    def load_validation(validation)
      type = validation['type'].capitalize
      validator = self.class.const_get("#{type}")
      if validation['description'].nil?
        raise InvalidSchema, "validators requires description"
      end
      validator.new(self, validation['condition'], validation['description'])
    end

    class ValidatorBase
      attr_reader :schema, :condition, :description

      def initialize(schema, condition, description)
        @schema = schema
        @condition = condition
        @description = description
      end

      def valid? (input)
        return false unless input.is_a? String
        return run(input)
      end

      def validate(input)
        {
          'validity' => valid?(input),
          'description' => description,
        }
      end

      private
      def run(input)
        raise NotImplementedError
      end
    end

    class Required < ValidatorBase
      private
      def run(input)
        input.length > 0
      end
    end
  end

  module SetValidators
    include Validators

    class SetValidatorBase < ValidatorBase
      def valid? (input)
        return false unless input.is_a? Array
        return run(input)
      end
    end

    class Maxchoices
      private
      def run(input)
        input.length <= condition.to_i
      end
    end

    class Minchoices
      private
      def run(input)
        input.length >= condition.to_i
      end
    end
  end

  module IntegerValidators
    include Validators

    class Number < ValidatorBase
      private
      def run(input)
        return true if input.length.zero?
        Integer(input)
        true
      rescue
        false
      end
    end

    class Min < ValidatorBase
      private
      def run(input)
        return true if input.length.zero?
        Integer(input) >= condition.to_i
      rescue
        false
      end
    end

    class Max < ValidatorBase
      private
      def run(input)
        return true if input.length.zero?
        Integer(input) <= condition.to_i
      rescue
        false
      end
    end
  end

  module StringValidators
    include Validators

    class Pattern < ValidatorBase
      private
      def run(input)
        return true if input.length.zero?
        input.match(condition) != nil
      end
    end

    class Minlength < ValidatorBase
      private
      def run(input)
        return true if input.length.zero?
        input.length >= condition.to_i
      end
    end

    class Maxlength < ValidatorBase
      private
      def run(input)
        return true if input.length.zero?
        input.length <= condition.to_i
      end
    end
  end

  module ChoiceValidators
    include Validators

    class Validchoice < ValidatorBase
      private
      def run(input)
        return true if input.length.zero?
        schema.choices.any? do |choice|
          choice['value'] == input
        end
      end
    end
  end

  module TableValidators
    include Validators

    class TableValidatorBase < ValidatorBase
      def valid? (input)
        return false unless input.is_a? Array
        return run(input)
      end
    end

    class Maxrows < TableValidatorBase
      private
      def run(input)
        return true if input.length.zero?
        input.length <= condition.to_i
      end
    end

    class Minrows < TableValidatorBase
      private
      def run(input)
        return true if input.length.zero?
        input.length >= condition.to_i
      end
    end

    class Required < TableValidatorBase
      private
      def run(input)
        input.length > 0
      end
    end
  end
end
