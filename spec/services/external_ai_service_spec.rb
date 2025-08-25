# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalAiService, type: :service do
  subject(:service) { described_class.new(payload) }

  let(:payload) do
    {
      urls: ['https://example.com/news-1'],
      temas: ['Transport'],
      menciones: ['Mention1'],
      ministerio: ['Ministerio de Cultura'],
      ministro: ['Ricardes']
    }
  end

  describe '#call' do
    context 'when AI service responds successfully' do
      let(:ai_response) do
        {
          'recibidas' => 1,
          'procesadas' => 1,
          'noticias' => [
            {
              'titulo' => 'Test News',
              'tipo_publicacion' => 'nota'
            }
          ],
          'errores' => []
        }
      end

      before do
        stub_request(:post, 'http://localhost:3001/v1/procesar-noticias')
          .with(body: payload.to_json)
          .to_return(status: 200, body: ai_response.to_json, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns transformed response' do
        result = service.call

        expect(result[:received]).to eq(1)
        expect(result[:processed]).to eq(1)
        expect(result[:news]).to be_present
        expect(result[:errors]).to be_empty
      end
    end

    context 'when AI service fails' do
      before do
        stub_request(:post, 'http://localhost:3001/v1/procesar-noticias')
          .to_return(status: 500)
      end

      it 'returns nil' do
        result = service.call
        expect(result).to be_nil
      end
    end

    context 'when connection fails' do
      before do
        stub_request(:post, 'http://localhost:3001/v1/procesar-noticias')
          .to_raise(Faraday::ConnectionFailed)
      end

      it 'returns nil and logs error' do
        expect(Rails.logger).to receive(:error).with(/AI service connection error/)
        result = service.call
        expect(result).to be_nil
      end
    end
  end
end
