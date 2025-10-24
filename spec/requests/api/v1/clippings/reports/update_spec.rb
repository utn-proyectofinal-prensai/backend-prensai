# frozen_string_literal: true

describe 'PATCH /api/v1/clippings/:clipping_id/report' do
  subject(:request_update_report) do
    patch api_v1_clipping_report_path(clipping),
          params: { clipping_report: report_params },
          headers: auth_headers,
          as: :json
  end

  include_context 'with authenticated admin user via JWT'

  let(:clipping) { create(:clipping, news_count: 1) }
  let(:report) { create(:clipping_report, clipping: clipping) }
  let(:report_params) do
    {
      content: 'Contenido actualizado del reporte',
      metadata: {
        'fecha_actualizacion' => '2025-08-17T11:00:00Z',
        'version' => '2.0'
      }
    }
  end

  before { report }

  it 'returns ok status' do
    request_update_report
    expect(response).to have_http_status(:ok)
  end

  it 'updates the report content' do
    request_update_report
    expect(report.reload.content).to eq('Contenido actualizado del reporte')
  end

  it 'updates the report metadata' do
    request_update_report
    expect(report.reload.metadata['fecha_actualizacion']).to eq('2025-08-17T11:00:00Z')
    expect(report.reload.metadata['version']).to eq('2.0')
  end

  it 'assigns the current user as reviewer' do
    request_update_report
    expect(report.reload.reviewer).to eq(admin_user)
  end

  it 'marks the report as manually edited' do
    request_update_report
    expect(report.reload.manually_edited?).to be true
  end

  it 'returns the updated report payload', :aggregate_failures do
    request_update_report

    updated_report = json[:clipping_report]
    expect(updated_report[:content]).to eq('Contenido actualizado del reporte')
    expect(updated_report[:metadata][:fecha_actualizacion]).to eq('2025-08-17T11:00:00Z')
    expect(updated_report[:metadata][:version]).to eq('2.0')
    expect(updated_report[:manually_edited]).to be true
    expect(updated_report[:reviewer][:id]).to eq(admin_user.id)
    expect(updated_report[:reviewer][:name]).to eq(admin_user.full_name)
    expect(updated_report[:clipping_id]).to eq(clipping.id)
  end

  context 'when report does not exist' do
    let(:clipping) { create(:clipping, news_count: 1) }

    before do
      # Ensure no report exists for this clipping
      clipping.report&.destroy
    end

    it 'returns not found' do
      request_update_report
      expect(response).to have_http_status(:not_found)
    end
  end

  context 'when validation fails' do
    let(:report_params) { { content: '' } }

    it 'returns unprocessable entity' do
      request_update_report
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:errors]).to be_present
    end
  end

  context 'when user is not the creator' do
    include_context 'with authenticated regular user via JWT'

    let(:clipping) { create(:clipping, creator: create(:user)) }

    it 'returns forbidden' do
      request_update_report
      expect(response).to have_http_status(:forbidden)
    end
  end

  context 'when user is the creator' do
    include_context 'with authenticated regular user via JWT'

    let(:clipping) { create(:clipping, creator: regular_user) }

    it 'allows the update' do
      request_update_report
      expect(response).to have_http_status(:ok)
      expect(report.reload.content).to eq('Contenido actualizado del reporte')
      expect(report.reload.reviewer).to eq(regular_user)
    end
  end

  context 'when the request is unauthenticated' do
    let(:auth_headers) { {} }

    it 'returns unauthorized' do
      request_update_report
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
