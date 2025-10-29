# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalAiService, type: :service do
  let(:service) { described_class.new(payload: payload, action: :process_news) }
  let(:base_url) { 'http://ai.example.com' }
  let!(:base_config) do
    create(:ai_configuration, key: 'AI_MODULE_BASE_URL', value: base_url, value_type: 'string', internal: true)
  end

  let(:payload) do
    {
      urls: ['https://example.com/news-1'],
      temas: ['Transport'],
      menciones: ['Mention1'],
      ministerios_key_words: ['Ministerio de Cultura'],
      ministro_key_words: ['Ricardes']
    }
  end

  def with_modified_env(env)
    original_env = {}
    env.each do |key, value|
      original_env[key] = ENV.fetch(key, nil)
      ENV[key] = value
    end
    yield
  ensure
    env.each_key { |key| ENV[key] = original_env[key] }
  end

  describe '#call' do
    context 'when AI service responds successfully' do
      let(:ai_response) do
        {
          'recibidas' => 1,
          'procesadas' => 1,
          'data' => [
            {
              'TITULO' => 'Test News',
              'TIPO PUBLICACION' => 'nota'
            }
          ],
          'errores' => []
        }
      end

      before do
        stub_request(:post, "#{base_url}/procesar-noticias")
          .to_return(status: 200, body: ai_response.to_json, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns transformed response' do
        result = service.call

        expect(result[:received]).to eq(1)
        expect(result[:processed]).to eq(1)
        expect(result[:news]).to be_present
        expect(result[:errors]).to be_empty
      end

      it 'transforms response keys correctly' do
        result = service.call

        expect(result[:received]).to eq(1)
        expect(result[:processed]).to eq(1)
        expect(result[:news]).to eq(ai_response['data'])
        expect(result[:errors]).to eq(ai_response['errores'])
      end
    end

    context 'when AI service fails with non-success status' do
      before do
        stub_request(:post, "#{base_url}/procesar-noticias")
          .to_return(status: 500, body: 'Internal Server Error')
      end

      it 'returns nil and logs error' do
        result = service.call
        expect(result[:ok]).to be false
      end
    end

    context 'when AI service returns invalid response structure' do
      let(:invalid_response) do
        {
          'recibidas' => 1
          # Missing required fields: 'procesadas' and 'data'
        }
      end

      before do
        stub_request(:post, "#{base_url}/procesar-noticias")
          .to_return(status: 200, body: invalid_response.to_json, headers: { 'Content-Type' => 'application/json' })
      end

      it 'raises error for missing required fields' do
        expect { service.call }.to raise_error(StandardError, /missing required fields/)
      end
    end

    context 'when connection fails' do
      before do
        stub_request(:post, "#{base_url}/procesar-noticias")
          .to_raise(Faraday::ConnectionFailed)
      end

      it 'returns nil and logs error' do
        result = service.call
        expect(result).to be_nil
      end
    end

    context 'when JSON parsing fails' do
      before do
        stub_request(:post, "#{base_url}/procesar-noticias")
          .to_return(status: 200, body: 'invalid json', headers: { 'Content-Type' => 'application/json' })
      end

      it 'handles JSON parsing errors gracefully' do
        result = service.call
        expect(result).to be_nil
      end
    end
  end

  describe 'URL configuration' do
    it 'uses the database value when present' do
      expect(service.send(:ai_module_base_url)).to eq(base_url)
    end

    it 'falls back to ENV when configuration is absent' do
      base_config.destroy!
      env_url = 'http://env-ai.example.com'

      with_modified_env('AI_MODULE_BASE_URL' => env_url) do
        expect(service.send(:ai_module_base_url)).to eq(env_url)
      end
    end

    it 'raises when no base URL is configured' do
      base_config.destroy!

      expect {
        service.send(:ai_module_base_url)
      }.to raise_error(ExternalAiService::MissingConfigurationError)
    end
  end

  describe 'fallback URL handling' do
    let(:fallback_url) { 'http://ai-fallback.example.com' }
    let!(:fallback_config) do
      create(:ai_configuration, key: 'AI_MODULE_FALLBACK_BASE_URL', value: fallback_url, value_type: 'string',
                                internal: true)
    end

    let(:ai_response) do
      {
        'recibidas' => 1,
        'procesadas' => 1,
        'data' => [],
        'errores' => []
      }
    end

    it 'uses the fallback URL when the primary connection fails' do
      stub_request(:post, "#{base_url}/procesar-noticias").to_raise(Faraday::ConnectionFailed)
      stub_request(:post, "#{fallback_url}/procesar-noticias")
        .to_return(status: 200, body: ai_response.to_json, headers: { 'Content-Type' => 'application/json' })

      result = service.call

      expect(result[:ok]).to be true
      expect(WebMock).to have_requested(:post, "#{fallback_url}/procesar-noticias")
    end

    it 'does not use the fallback when the primary returns a non-success status' do
      stub_request(:post, "#{base_url}/procesar-noticias").to_return(status: 500, body: 'Internal Server Error')

      result = service.call

      expect(result[:ok]).to be false
      expect(WebMock).to have_requested(:post, "#{base_url}/procesar-noticias")
      expect(WebMock).not_to have_requested(:post, "#{fallback_url}/procesar-noticias")
    end
  end

  describe 'custom endpoint handling' do
    let(:payload) { { metricas: { totalNoticias: 1 } } }
    let(:custom_response) do
      {
        'informe' => 'Contenido',
        'metadatos' => {
          'fecha_generacion' => '2025-08-17',
          'tiempo_generacion' => '5s',
          'total_tokens' => 123
        }
      }
    end

    before do
      stub_request(:post, "#{base_url}/generate-informe")
        .to_return(status: 200, body: custom_response.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'transforms report responses into clipping payload' do
      response = described_class.generate_report(payload)

      expect(response[:ok]).to be true
      expect(response[:content]).to eq('Contenido')
      expect(response[:metadata]['total_tokens']).to eq(123)
    end
  end

  describe 'HTTP client configuration' do
    it 'configures Faraday with JSON request and response' do
      client = service.send(:http_client)

      expect(client.builder.handlers).to include(Faraday::Request::Json)
      expect(client.builder.handlers).to include(Faraday::Response::Json)
    end
  end
end
