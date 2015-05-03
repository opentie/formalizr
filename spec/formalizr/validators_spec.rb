require 'spec_helper'

module Formalizr::StringValidators
  describe Formalizr::StringValidators do
    describe Pattern do
      subject do
        Pattern.new('^[a-z]+$', 'contains lower alphabet only')
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
        Minlength.new('5', 'minlength is 5')
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
        Maxlength.new('10', 'maxlength is 10')
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

module Formalizr::IntegerValidators
  describe Formalizr::IntegerValidators do
    describe Min do
      subject do
        Min.new('10', 'minimum value is 10')
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
        Max.new('10', 'maximum value is 10')
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

module Formalizr::Validators
  describe Formalizr::Validators do
    describe Required do
      subject do
        Required.new(nil, 'required')
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
