require 'spec_helper'

module Formalizr::StringValidators
  describe Formalizr::StringValidators do
    describe Pattern do
      subject do
        # FIXME
        Pattern.new(nil, '^[a-z]+$', 'contains lower alphabet only')
      end

      it 'returns true when matched' do
        expect(subject.valid?('matched')).to eq(true)
      end

      it 'returns false when not matched' do
        expect(subject.valid?('not-matched')).to eq(false)
      end

      it 'returns true when empty' do
        expect(subject.valid?('')).to eq(true)
      end
    end

    describe Minlength do
      subject do
        # FIXME
        Minlength.new(nil, '5', 'minlength is 5')
      end

      it 'returns true when matched' do
        expect(subject.valid?('matched')).to eq(true)
      end

      it 'returns false when not matched' do
        expect(subject.valid?('not')).to eq(false)
      end

      it 'returns true when empty' do
        expect(subject.valid?('')).to eq(true)
      end
    end

    describe Maxlength do
      subject do
        # FIXME
        Maxlength.new(nil, '10', 'maxlength is 10')
      end

      it 'returns true when matched' do
        expect(subject.valid?('matched')).to eq(true)
      end

      it 'returns false when not matched' do
        expect(subject.valid?('not-matched')).to eq(false)
      end

      it 'returns true when empty' do
        expect(subject.valid?('')).to eq(true)
      end
    end
  end
end

module Formalizr::ChoiceValidators
  describe Formalizr::ChoiceValidators do
    describe Validchoice do
      subject do
        Validchoice.new(
          Formalizr::InputSchema.load({
            'name' => 'soleil',
            'type' => 'select',
            'title' => 'Soleil',
            'note' => 'soleil rising',
            'choices' => [
              { 'label' => 'please select' },
              { 'value' => 'ichigo' },
              { 'value' => 'aoi' },
              { 'value' => 'ran' }
            ],
            'validators' => [
              { 'type' => 'validchoice', 'description' => 'select one from soleil member' }
            ]
          }),
          nil,
          'value must exist in choices')
      end

      it 'returns true when matched' do
        expect(subject.valid?('ichigo')).to eq(true)
        expect(subject.valid?('aoi')).to eq(true)
      end

      it 'returns false when not matched' do
        pending
        expect(subject.valid?('akari')).to eq(false)
        expect(subject.valid?('please select')).to eq(false)
      end
    end
  end
end

module Formalizr::IntegerValidators
  describe Formalizr::IntegerValidators do
    describe Min do
      subject do
        # FIXME
        Min.new(nil, '10', 'minimum value is 10')
      end

      it 'returns true when matched' do
        expect(subject.valid?('10')).to eq(true)
        expect(subject.valid?('11')).to eq(true)
      end

      it 'returns false when not matched' do
        expect(subject.valid?('not-a-integer')).to eq(false)
        expect(subject.valid?('9')).to eq(false)
        expect(subject.valid?('5')).to eq(false)
      end

      it 'returns true when empty' do
        expect(subject.valid?('')).to eq(true)
      end
    end

    describe Max do
      subject do
        # FIXME
        Max.new(nil, '10', 'maximum value is 10')
      end

      it 'returns true when matched' do
        expect(subject.valid?('10')).to eq(true)
        expect(subject.valid?('9')).to eq(true)
        expect(subject.valid?('-10')).to eq(true)
      end

      it 'returns false when not matched' do
        expect(subject.valid?('not-a-integer')).to eq(false)
        expect(subject.valid?('11')).to eq(false)
        expect(subject.valid?('100')).to eq(false)
      end

      it 'returns true when empty' do
        expect(subject.valid?('')).to eq(true)
      end
    end

  end
end

module Formalizr::TableValidators
  describe Formalizr::TableValidators do
    describe Maxrows do
      subject do
        Maxrows.new(
          Formalizr::TableInputSchema.load({
            'name' => 'goods',
            'title' => 'goods',
            'type' => 'table',
            'note' => '',
            'columns' => [
              {
                'name' => 'name',
                'type' => 'text',
                'title' => 'hoge',
              }
            ]
          }),
          '3',
          'max 3 rows')
      end

      it 'returns true when empty' do
        expect(subject.valid?([])).to eq(true)
      end      

      it 'returns true when only 3 rows' do
        expect(subject.valid?([
          { 'name' => 'foo' },
          { 'name' => 'bar' },
          { 'name' => 'baz' },
        ])).to eq(true)
      end

      it 'returns false when 4 rows' do
        expect(subject.valid?([
          { 'name' => 'foo' },
          { 'name' => 'bar' },
          { 'name' => 'baz' },
          { 'name' => 'hoge' },
        ])).to eq(false)
      end
    end
  end
end

module Formalizr::Validators
  describe Formalizr::Validators do
    describe Required do
      subject do
        # FIXME
        Required.new(nil, nil, 'required')
      end

      it 'returns true when not empty' do
        expect(subject.valid?(' ')).to eq(true)
        expect(subject.valid?('a')).to eq(true)
        expect(subject.valid?('The quick brown fox jumps over the lazy dog')).to eq(true)
      end

      it 'returns false when empty' do
        expect(subject.valid?('')).to eq(false)
      end
    end
  end
end
