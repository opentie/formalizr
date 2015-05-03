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
          'columns' => [
            {
              'name'  => 'text',
              'type'  => 'text',
              'title' => '書く',
              'note'  => '書ける',
              'validators' => [
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
                { 'text' => 'foo' }
              ]
            })
          ).to eq({
            'text' => {
              'validities' => [
                { 'validity' => false, 'description' => 'hoge' },
                { 'validity' => true, 'description' => 'foo' },
              ]
            },
            'table' => {
              'validities' => [],
              'children' => [
                {
                  'text' => {
                    'validities' => [
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
          ).to eq({
            'text' => {
              'validities' => [
                { 'validity' => true, 'description' => 'hoge' },
                { 'validity' => true, 'description' => 'foo' },
              ]
            },
            'table' => {
              'validities' => [],
              'children' => []
            }
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
