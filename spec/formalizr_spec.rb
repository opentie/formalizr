require 'spec_helper'

module Formalizr
  describe Formalizr do
    it 'has a version number' do
      expect(Formalizr::VERSION).not_to be nil
    end

    it 'does something useful' do
      expect(false).to eq(false)
    end

    describe FormSchema do
      subject do
        FormSchema.new([{
          'name'  => 'text',
          'type'  => 'text',
          'title' => '書く',
          'note'  => '書ける',
          'validators' => [
            { 'type' => 'maxlength', 'condition' => '4', 'description' => 'hoge' },
            { 'type' => 'minlength', 'condition' => '3', 'description' => 'foo' },
          ]
        }, {
          'name' => 'table',
          'type' => 'table',
          'title' => '表',
          'note' => 'note',
          'validators' => [
            { 'type' => 'required',                     'description' => 'bar' },
            { 'type' => 'maxrows' , 'condition' => '2', 'description' => 'baz' },
          ],
          'columns' => [
            {
              'name'  => 'text',
              'type'  => 'text',
              'title' => '書く',
              'note'  => '書ける',
              'validators' => [
                { 'type' => 'required' ,                     'description' => 'bar' },
                { 'type' => 'maxlength', 'condition' => '4', 'description' => 'hoge' },
                { 'type' => 'minlength', 'condition' => '3', 'description' => 'foo' },
              ]
            }
          ]
        }])
      end

      describe '#validate' do
        it 'validate' do
          expect(
            subject.validate({
              'text' => 'hogefoobar',
              'table' => [
                { 'text' => 'foo' },
                { 'text' => 'bar' },
                { 'text' => 'baz' }
              ]
            })
          ).to match({
            'text' => {
              'validities' => [
                { 'validity' => false, 'description' => 'hoge' },
                { 'validity' => true , 'description' => 'foo' },
              ]
            },
            'table' => {
              'validities' => [
                { 'validity' => true , 'description' => 'bar' },
                { 'validity' => false, 'description' => 'baz' }
              ],
              'children' => [
                {
                  'text' => {
                    'validities' => [
                      { 'validity' => true, 'description' => 'bar'},
                      { 'validity' => true, 'description' => 'hoge' },
                      { 'validity' => true, 'description' => 'foo' },
                    ]
                  }
                },
                {
                  'text' => {
                    'validities' => [
                      { 'validity' => true, 'description' => 'bar'},
                      { 'validity' => true, 'description' => 'hoge' },
                      { 'validity' => true, 'description' => 'foo' },
                    ]
                  }
                },
                {
                  'text' => {
                    'validities' => [
                      { 'validity' => true, 'description' => 'bar'},
                      { 'validity' => true, 'description' => 'hoge' },
                      { 'validity' => true, 'description' => 'foo' },
                    ]
                  }
                }
              ]
            }
          })
        end

        it 'returns true as validity if input is empty' do
          expect(
            subject.validate({ 'text' => '' })
          ).to match({
            'text' => {
              'validities' => [
                { 'validity' => true, 'description' => 'hoge' },
                { 'validity' => true, 'description' => 'foo' },
              ]
            },
            'table' => {
              'validities' => [
                { 'validity' => false, 'description'=>'bar' },
                { 'validity' => true , 'description'=>'baz' }
              ],
              'children' => []
            }
          })
        end
      end

      describe '#normalize' do
        it 'normalize' do
          expect(
            subject.normalize({
              'text' => 'foo',
              'table' => [
                { 'text' => 'foo' },
                { 'text' => 'hoge' },
              ],
            })
          ).to match({
            'text' => 'foo',
            'table' => [
              { 'text' => 'foo' },
              { 'text' => 'hoge' },
            ],
          })
        end
      end
    end    

    describe InputSchema do
      describe '.load' do
        subject do
          InputSchema.load({
            'name'  => 'text',
            'type'  => 'text',
            'title' => '書く',
            'note'  => '書ける',
            'validators' => [
              { 'type' => 'maxlength', 'condition' => '4', 'description' => 'hoge' },
              { 'type' => 'minlength', 'condition' => '3', 'description' => 'foo' },
            ]
          })
        end

        it 'loads definition' do
          expect(subject).to be_a(TextInputSchema)
        end
      end
    end
  end
end
