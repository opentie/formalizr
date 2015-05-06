require 'spec_helper'

module Formalizr
  describe Formalizr do
    describe Querier do
      subject do
        class Model
          include Querier

          def payload
            {
              'many' => [
                {
                  'name' => 'アレ',
                  'count' => 10
                },
                {
                  'name' => 'ソレ',
                  'count' => 100
                }
              ],
              'name' => 'ほげ',
              'desc' => 'ほげほげあ'
            }
          end
        end
        Model.new
      end

      it 'queries' do
        expect(
          subject.query({
            'type' => 'infix',
            'operator' => 'equal',
            'left' => {
              'type' => 'field',
              'field' => 'name',
            },
            'right' => {
              'type' => 'literal',
              'literal' => 'ほげ'
            },
          })
        ).to eq(true)

        expect(
          subject.query({
            'type' => 'infix',
            'operator' => 'exists_equal',
            'left' => {
              'type' => 'field',
              'field' => 'name',
            },
            'right' => {
              'type' => 'literal',
              'literal' => ['あ', 'い']
            },
          })
        ).to eq(false)
        
        expect(
          subject.query({
            'type' => 'field',
            'field' => 'name',
          })
        ).to eq('ほげ')

        expect(
          subject.query({
            'type' => 'table_column',
            'table' => 'many',
            'column' => 'name',
          })
        ).to eq(['アレ', 'ソレ'])
      end
    end
  end
end
