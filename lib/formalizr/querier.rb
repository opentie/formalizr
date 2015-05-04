require "active_support/concern"

module Formalizr
  module Querier
    def query(thunk)
      thunk.evaluate(payload)
    end
  end

  module Query
    class Thunk
      def initialize(query_hash)
        @type = query_hash['type']
      end

      def self.from_json(query_hash)
        type = query_hash['type']
        type_class = Query.const_get("#{type.camelize}")
        type_class.new(query_hash)
      end

      def evaluate(scope)
        raise NotImplementedError
      end
    end

    class Operator < Thunk
      def initialize(query_hash)
        super(query_hash)
        @operator = query_hash['operator']
      end
    end

    class Infix < Operator
      def initialize(query_hash)
        super(query_hash)
        @infix = Operators.method("op_#{@operator}")
        @left = Thunk.from_json(query_hash['left'])
        @right = Thunk.from_json(query_hash['right'])
      end

      def evaluate(scope)
        @infix.call(@left.evaluate(scope), @right.evaluate(scope))
      end
    end

    class Literal < Thunk
      def initialize(query_hash)
        super(query_hash)
        @literal = query_hash['literal']
      end      
      
      def evaluate(scope)
        @literal
      end
    end

    class Field < Thunk
      def initialize(query_hash)
        super(query_hash)
        @field_name = query_hash['field']
      end

      def evaluate(scope)
        scope[@field_name]
      end
    end

    class TableColumn < Thunk
      def initialize(query_hash)
        super(query_hash)
        @table_name = query_hash['table']
        @column_name = query_hash['column']
      end

      def evaluate(scope)
        table = scope[@table_name]
        return [] if table.nil?
        table.map{ |row| row[@column_name] }
      end
    end
  end
  
  module Operators
    class InvalidQuery < StandardError ; end
    
    def self.op_equal(left, right)
      left == right
    end

    def self.op_not_equal(left, right)
      left != right
    end

    def self.op_less_than(left, right)
      left < right
    end

    def self.op_less_than_or_equal(left, right)
      op_less_than(left, right) || op_equal(left, right)
    end

    def self.op_greater_than(left, right)
      left > right
    end

    def self.op_greater_than_or_equal(left, right)
      op_greater_than(left, right) || op_equal(left, right)
    end

    def self.array_in_left_hand(left, right)
      is_left_array = left.is_a? Array
      is_right_array = right.is_a? Array
      raise InvalidQuery if is_left_array && is_right_array
      raise InvalidQuery if !is_left_array && !is_right_array
      if is_left_array && !is_right_array
        [left, right, false]
      else
        [right, left, true]
      end
    end

    def self.op_all_equal(*args)
      left, right, _ = array_in_left_hand(*args)
      left.all? { |left_elem| op_equal(left_elem, right) }
    end

    def self.op_all_not_equal(*args)
      left, right, _ = array_in_left_hand(*args)
      left.all? { |left_elem| op_not_equal(left_elem, right) }
    end

    def self.op_all_less_than(*args)
      left, right, reversed = array_in_left_hand(*args)
      return op_all_greater_than(left, right) if reversed
      left.all? { |left_elem| op_less_than(left_elem, right) }
    end

    def self.op_all_less_than_or_equal(*args)
      left, right, reversed = array_in_left_hand(*args)
      return op_all_greater_than_or_equal(left, right) if reversed
      left.all? { |left_elem| op_less_than_or_equal(left_elem, right) }
    end

    def self.op_all_greater_than(*args)
      left, right, reversed = array_in_left_hand(*args)
      return op_all_less_than(left, right) if reversed
      left.all? { |left_elem| op_greater_than(left_elem, right) }
    end

    def self.op_all_greater_than_or_equal(*args)
      left, right, reversed = array_in_left_hand(*args)
      return op_all_less_than_or_equal(left, right) if reversed
      left.all? { |left_elem| op_greater_than_or_equal(left_elem, right) }
    end

    def self.op_exists_equal(*args)
      left, right, _ = array_in_left_hand(*args)
      left.any? { |left_elem| op_equal(left_elem, right) }
    end

    def self.op_exists_equal(*args)
      left, right, _ = array_in_left_hand(*args)
      left.any? { |left_elem| op_not_equal(left_elem, right) }
    end

    def self.op_exists_less_than(*args)
      left, right, reversed = array_in_left_hand(*args)
      return op_all_greater_than(left, right) if reversed
      left.any? { |left_elem| op_less_than(left_elem, right) }
    end

    def self.op_exists_less_than_or_equal(*args)
      left, right, reversed = array_in_left_hand(*args)
      return op_all_greater_than_or_equal(left, right) if reversed
      left.any? { |left_elem| op_less_than_or_equal(left_elem, right) }
    end

    def self.op_exists_greater_than(*args)
      left, right, reversed = array_in_left_hand(*args)
      return op_all_less_than(left, right) if reversed
      left.any? { |left_elem| op_greater_than(left_elem, right) }
    end

    def self.op_exists_greater_than_or_equal(*args)
      left, right, reversed = array_in_left_hand(*args)
      return op_all_less_than_or_equal(left, right) if reversed
      left.any? { |left_elem| op_greater_than_or_equal(left_elem, right) }
    end
  end
end
