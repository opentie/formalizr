require "formalizr/version"

module Formalizr
  module Validators
    class Validator
      attr_reader :condition, :description

      def initialize(condition, description)
        @condition = condition
        @description = description
      end

      def valid? (input)
        return false unless String === input
        return validate(input)
      end

      def validate(input)
        raise NotImplementedError
      end
    end

    class Pattern < Validator
      def validate(input)
        return true if input.length.zero?
        input.match(condition) != nil
      end
    end

    class Minlength < Validator
      def validate(input)
        return true if input.length.zero?
        input.length >= condition.to_i
      end
    end

    class Maxlength < Validator
      def validate(input)
        return true if input.length.zero?
        input.length <= condition.to_i
      end
    end

    class Min < Validator
      def validate(input)
        return true if input.length.zero?
        Integer(input) >= condition.to_i
      rescue
        false
      end
    end

    class Max < Validator
      def validate(input)
        return true if input.length.zero?
        Integer(input) <= condition.to_i
      rescue
        false
      end
    end

    class Required < Validator
      def validate(input)
        input.length > 0
      end
    end
  end
end
