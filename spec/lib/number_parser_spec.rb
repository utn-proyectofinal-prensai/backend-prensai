# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NumberParser do
  describe '.parse_currency' do
    context 'when value is nil or empty' do
      it 'returns nil for nil' do
        expect(described_class.parse_currency(nil)).to be_nil
      end

      it 'returns nil for empty string' do
        expect(described_class.parse_currency('')).to be_nil
      end

      it 'returns nil for whitespace string' do
        expect(described_class.parse_currency('   ')).to be_nil
      end
    end

    context 'when value is already numeric' do
      it 'returns the same value for Numeric types' do
        expect(described_class.parse_currency(100.50)).to eq(100.50)
        expect(described_class.parse_currency(100)).to eq(100)
      end
    end

    context 'when parsing currency strings' do
      it 'handles European format (1.234,56)' do
        result = described_class.parse_currency('1.234,56')
        expect(result).to eq(BigDecimal('1234.56'))
      end

      it 'handles currency symbols' do
        result = described_class.parse_currency('$75.000')
        expect(result).to eq(BigDecimal(75_000))
      end

      it 'handles comma as decimal separator' do
        result = described_class.parse_currency('100,50')
        expect(result).to eq(BigDecimal('100.50'))
      end

      it 'handles dot as decimal separator' do
        result = described_class.parse_currency('100.50')
        expect(result).to eq(BigDecimal('100.50'))
      end
    end
  end

  describe '.parse_audience_size' do
    it 'removes separators and returns integer' do
      expect(described_class.parse_audience_size('3.500')).to eq(3500)
      expect(described_class.parse_audience_size('3,500')).to eq(3500)
    end

    it 'returns the same value for integers' do
      expect(described_class.parse_audience_size(3500)).to eq(3500)
    end
  end
end
