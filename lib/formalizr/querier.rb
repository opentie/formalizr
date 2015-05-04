module Formalizr
  module Querier
    class InvalidQuery < StandardError ; end

    def self.eval_expression(payload, expression)
      #FIXME: too dirty
      JSON.parse("{\"value\": #{expression}}")['value']
    rescue
      case expression
      when /^(.+?)->(.+)$/
        rows = payload[$1]
        return [] if rows.nil?
        rows.map{ |row| row[$2] }
      else
        payload[expression]
      end
    end

    def self.query(records, condition)
      left_name = condition['left']
      right_name = condition['right']
      op_name = condition['op']
      op = Operators.method("op_#{op_name}")
      records.select do |record|
        left = eval_expression(record.payload, left_name)
        right = eval_expression(record.payload, right_name)
        op.call(left, right)
      end
    end

    module Operators
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
end
