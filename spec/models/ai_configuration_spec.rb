# frozen_string_literal: true

require 'rails_helper'

describe AiConfiguration do
  describe 'validations' do
    subject { build(:ai_configuration) }

    it { is_expected.to validate_presence_of(:key) }
    it { is_expected.to validate_presence_of(:display_name) }
    it { is_expected.to validate_presence_of(:value_type) }
    it { is_expected.to validate_uniqueness_of(:key) }
    it { is_expected.to validate_inclusion_of(:value_type).in_array(%w[array string reference]) }

    describe 'value_type_matches_value' do
      context 'when value_type is array' do
        let(:config) { build(:ai_configuration, :array_type) }

        it 'is valid with array value' do
          expect(config).to be_valid
        end

        it 'is invalid with non-array value' do
          config.value = 'not an array'
          expect(config).not_to be_valid
          expect(config.errors[:value]).to be_present
        end
      end

      context 'when value_type is string' do
        let(:config) { build(:ai_configuration, value_type: 'string', value: 'test string') }

        it 'is valid with string value' do
          expect(config).to be_valid
        end

        it 'is invalid with non-string value' do
          config.value = 123
          expect(config).not_to be_valid
          expect(config.errors[:value]).to be_present
        end
      end

      context 'when value_type is reference' do
        let(:config) { build(:ai_configuration, :reference_type) }

        it 'is valid with integer value' do
          expect(config).to be_valid
        end

        it 'is invalid with non-integer value' do
          config.value = 'not an integer'
          expect(config).not_to be_valid
          expect(config.errors[:value]).to be_present
        end
      end

      context 'when value is nil' do
        let(:config) { build(:ai_configuration, value: nil) }

        it 'is valid' do
          expect(config).to be_valid
        end
      end
    end

    describe 'valid_reference_type' do
      context 'when reference_type is nil' do
        let(:config) { build(:ai_configuration, reference_type: nil) }

        it 'is valid' do
          expect(config).to be_valid
        end
      end

      context 'when reference_type is Topic' do
        let(:config) { build(:ai_configuration, reference_type: 'Topic') }

        it 'is valid' do
          expect(config).to be_valid
        end
      end

      context 'when reference_type is Mention' do
        let(:config) { build(:ai_configuration, reference_type: 'Mention') }

        it 'is valid' do
          expect(config).to be_valid
        end
      end

      context 'when reference_type is invalid' do
        let(:config) { build(:ai_configuration, reference_type: 'InvalidType') }

        it 'is invalid' do
          expect(config).not_to be_valid
          expect(config.errors[:reference_type]).to include('is not valid')
        end
      end
    end
  end

  describe '#options' do
    context 'when value_type is reference and reference_type is Topic' do
      let(:config) { create(:ai_configuration, :reference_type) }

      it 'returns an array of options with value and label structure' do
        options = config.options
        expect(options).to be_an(Array)
        options.each do |option|
          expect(option).to have_key(:value)
          expect(option).to have_key(:label)
          expect(option[:value]).to be_a(Integer)
          expect(option[:label]).to be_a(String)
        end
      end
    end

    context 'when value_type is not reference' do
      let(:config) { create(:ai_configuration, value_type: 'string') }

      it 'returns nil' do
        expect(config.options).to be_nil
      end
    end
  end

  describe '.get_value' do
    before { create(:ai_configuration, key: 'test_key', value: 'test_value') }

    it 'returns the value for existing key' do
      expect(described_class.get_value('test_key')).to eq('test_value')
    end

    it 'returns nil for non-existing key' do
      expect(described_class.get_value('non_existing_key')).to be_nil
    end
  end
end
