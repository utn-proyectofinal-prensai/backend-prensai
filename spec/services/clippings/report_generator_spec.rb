# frozen_string_literal: true

RSpec.describe Clippings::ReportGenerator, type: :service do
  subject(:generate_report) { described_class.call(clipping) }

  let(:clipping) { create(:clipping, news_count: 2) }
  let(:service_response) do
    {
      ok: true,
      content: 'Nuevo informe',
      metadata: {
        'fecha_generacion' => '2025-08-17T10:00:00Z',
        'tiempo_generacion' => '5s',
        'total_tokens' => 1234
      }
    }
  end

  before do
    allow(ExternalAiService).to receive(:generate_report).and_return(service_response)
  end

  describe '.call' do
    it 'returns a successful result' do
      result = generate_report

      expect(result).to be_success
      expect(result.payload).to be_a(ClippingReport)
      expect(result.payload.content).to eq('Nuevo informe')
    end

    it 'persists the report for the clipping' do
      expect { generate_report }.to change { clipping.reload.report&.content }.to('Nuevo informe')
    end

    it 'passes the expected payload to ExternalAiService' do
      generate_report

      expect(ExternalAiService).to have_received(:generate_report).with(hash_including(:metricas))
    end

    context 'when external service returns errors' do
      let(:service_response) { { ok: false, errors: ['timeout'] } }

      it 'returns a failure result' do
        result = generate_report

        expect(result).to be_failure
        expect(result.errors).to eq(['timeout'])
      end
    end

    context 'when external service is unreachable' do
      let(:service_response) { nil }

      it 'returns a failure result' do
        result = generate_report

        expect(result).to be_failure
        expect(result.errors).to eq(['External AI service is unreachable'])
      end
    end

    context 'when report persistence fails' do
      before do
        allow_any_instance_of(ClippingReport).to receive(:update!).and_raise(StandardError, 'DB error')
      end

      it 'returns a failure result with the error message' do
        result = generate_report

        expect(result).to be_failure
        expect(result.errors.first).to match(/Report generation failed: DB error/)
      end
    end
  end
end
