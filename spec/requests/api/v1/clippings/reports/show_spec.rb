# frozen_string_literal: true

describe 'GET /api/v1/clippings/:clipping_id/report' do
  subject(:request_show_report) do
    get api_v1_clipping_report_path(clipping), headers: auth_headers, as: :json
  end

  include_context 'with authenticated admin user via JWT'

  let(:clipping) { create(:clipping, news_count: 1) }

  context 'when report exists' do
    let!(:report) { create(:clipping_report, clipping: clipping) }

    it 'returns the persisted report' do
      request_show_report

      expect(response).to have_http_status(:ok)
      expect(json.dig(:clipping_report, :id)).to eq(report.id)
    end
  end

  context 'when report does not exist' do
    it 'returns not found' do
      request_show_report
      expect(response).to have_http_status(:not_found)
    end
  end

  context 'when the request is unauthenticated' do
    let(:auth_headers) { {} }

    before { create(:clipping_report, clipping: clipping) }

    it 'returns unauthorized' do
      request_show_report
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
