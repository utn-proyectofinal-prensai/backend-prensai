# frozen_string_literal: true

describe 'POST /api/v1/clippings/:clipping_id/report' do
  subject(:request_create_report) do
    post api_v1_clipping_report_path(clipping), headers: auth_headers, as: :json
  end

  include_context 'with authenticated admin user via JWT'

  let(:clipping) { create(:clipping, creator: admin_user) }

  context 'when the AI report generation succeeds' do
    let(:generated_content) { 'Resumen generado por la IA' }
    let(:generated_metadata) { { 'tone' => 'neutral', 'version' => '1.0' } }

    before do
      allow(Clippings::ReportGenerator).to receive(:call).with(clipping) do
        ServiceResult.new(
          success: true,
          payload: ClippingReport.create!(
            clipping: clipping,
            content: generated_content,
            metadata: generated_metadata
          )
        )
      end
    end

    it 'returns ok status' do
      request_create_report
      expect(response).to have_http_status(:ok)
    end

    it 'invokes the report generator service' do
      request_create_report
      expect(Clippings::ReportGenerator).to have_received(:call).with(clipping)
    end

    it 'creates a clipping report record' do
      expect { request_create_report }.to change(ClippingReport, :count).by(1)
    end

    it 'assigns the current user as creator of the report' do
      request_create_report
      expect(clipping.reload.report.creator).to eq(admin_user)
    end

    it 'returns the serialized report payload', :aggregate_failures do
      request_create_report

      report_payload = json[:clipping_report]
      expect(report_payload[:content]).to eq(generated_content)
      expect(report_payload[:metadata]).to eq(generated_metadata)
      expect(report_payload[:creator][:id]).to eq(admin_user.id)
      expect(report_payload[:creator][:name]).to eq(admin_user.full_name)
      expect(report_payload[:manually_edited]).to be(false)
    end
  end

  context 'when the AI service returns an error' do
    let(:error_messages) { ['External AI service is unreachable'] }

    before do
      allow(Clippings::ReportGenerator).to receive(:call).with(clipping).and_return(
        ServiceResult.new(success: false, errors: error_messages)
      )
    end

    it 'returns unprocessable entity' do
      request_create_report
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'does not create a clipping report' do
      expect { request_create_report }.not_to change(ClippingReport, :count)
    end

    it 'includes the error messages in the response body' do
      request_create_report
      expect(json[:errors]).to eq(error_messages)
    end
  end

  context 'when the user cannot manage the clipping' do
    include_context 'with authenticated regular user via JWT'

    let(:clipping) { create(:clipping, creator: create(:user)) }
    let(:report_generator) { Clippings::ReportGenerator }

    before do
      allow(report_generator).to receive(:call)
    end

    it 'returns forbidden' do
      request_create_report
      expect(response).to have_http_status(:forbidden)
      expect(report_generator).not_to have_received(:call)
    end
  end

  context 'when the request is unauthenticated' do
    let(:auth_headers) { {} }

    it 'returns unauthorized' do
      request_create_report
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
