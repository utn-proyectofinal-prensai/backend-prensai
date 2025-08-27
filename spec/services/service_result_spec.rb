# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServiceResult, type: :service do
  describe '#initialize' do
    context 'with success result' do
      subject(:result) { described_class.new(success: true, payload: { data: 'test' }) }

      it 'sets success to true' do
        expect(result.success?).to be true
      end

      it 'sets payload correctly' do
        expect(result.payload).to eq({ data: 'test' })
      end

      it 'sets failure to false' do
        expect(result.failure?).to be false
      end
    end

    context 'with failure result' do
      subject(:result) { described_class.new(success: false, error: 'Something went wrong') }

      it 'sets success to false' do
        expect(result.success?).to be false
      end

      it 'sets error correctly' do
        expect(result.error).to eq('Something went wrong')
      end

      it 'sets failure to true' do
        expect(result.failure?).to be true
      end
    end

    context 'with minimal parameters' do
      subject(:result) { described_class.new(success: true) }

      it 'initializes with default values' do
        expect(result.success?).to be true
        expect(result.payload).to be_nil
        expect(result.error).to be_nil
      end
    end
  end

  describe '#success?' do
    it 'returns true when success is true' do
      result = described_class.new(success: true)
      expect(result.success?).to be true
    end

    it 'returns false when success is false' do
      result = described_class.new(success: false)
      expect(result.success?).to be false
    end
  end

  describe '#failure?' do
    it 'returns true when success is false' do
      result = described_class.new(success: false)
      expect(result.failure?).to be true
    end

    it 'returns false when success is true' do
      result = described_class.new(success: true)
      expect(result.failure?).to be false
    end
  end

  describe 'attribute readers' do
    let(:payload) { { key: 'value' } }
    let(:error) { 'Error message' }
    let(:result) { described_class.new(success: true, payload: payload, error: error) }

    it 'provides read access to payload' do
      expect(result.payload).to eq(payload)
    end

    it 'provides read access to error' do
      expect(result.error).to eq(error)
    end
  end
end
