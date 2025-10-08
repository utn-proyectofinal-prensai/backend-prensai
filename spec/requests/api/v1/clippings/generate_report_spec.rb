# frozen_string_literal: true

describe 'POST /api/v1/clippings/:id/generate_report' do
  subject(:request_generate_report) do
    post generate_report_api_v1_clipping_path(clipping), headers: auth_headers, as: :json
  end

  include_context 'with authenticated admin user via JWT'

  let(:clipping) { create(:clipping, news_count: 2) }
  let(:service_response) do
    {
      ok: true,
      content: 'Informe generado',
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

  it 'returns ok status' do
    request_generate_report
    expect(response).to have_http_status(:ok)
  end

  it 'persists the clipping report' do
    expect { request_generate_report }.to change(ClippingReport, :count).by(1)
  end

  it 'returns the report payload', :aggregate_failures do
    request_generate_report

    report = json[:clipping_report]
    expect(report[:content]).to eq('Informe generado')
    expect(report[:metadata][:fecha_generacion]).to eq('2025-08-17T10:00:00Z')
    expect(report[:clipping_id]).to eq(clipping.id)
  end

  context 'when report already exists' do
    let!(:existing_report) do
      create(
        :clipping_report,
        clipping: clipping,
        content: 'Old content',
        metadata: {
          'fecha_generacion' => '2025-08-16T09:00:00Z',
          'tiempo_generacion' => '4s',
          'total_tokens' => 1000
        }
      )
    end

    it 'updates the existing report' do
      expect { request_generate_report }.not_to change(ClippingReport, :count)
      expect(existing_report.reload.content).to eq('Informe generado')
    end
  end

  context 'when external service returns an error' do
    let(:service_response) { { ok: false, errors: ['timeout'] } }

    it 'returns unprocessable entity' do
      request_generate_report
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:errors]).to eq(['timeout'])
    end
  end

  context 'when external service is unreachable' do
    let(:service_response) { nil }

    it 'returns unprocessable entity' do
      request_generate_report
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:errors]).to eq(['External AI service is unreachable'])
    end
  end

  context 'when user is not allowed' do
    include_context 'with authenticated regular user via JWT'

    let(:clipping) { create(:clipping) }

    it 'returns forbidden' do
      request_generate_report
      expect(response).to have_http_status(:forbidden)
    end
  end
end
