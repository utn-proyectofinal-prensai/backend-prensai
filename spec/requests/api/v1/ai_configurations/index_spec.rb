# frozen_string_literal: true

require 'rails_helper'

describe 'GET api/v1/ai_configurations' do
  subject { get api_v1_ai_configurations_path, headers: auth_headers, as: :json }

  let!(:enabled_config) { create(:ai_configuration, enabled: true, display_name: 'A Config') }
  let!(:disabled_config) { create(:ai_configuration, enabled: false, display_name: 'B Config') }
  let!(:another_enabled_config) { create(:ai_configuration, enabled: true, display_name: 'C Config') }

  context 'when authenticated as admin user' do
    include_context 'with authenticated admin user via JWT'

    it 'returns a successful response' do
      subject
      expect(response).to have_http_status(:success)
    end

    it 'returns an array of configurations' do
      subject
      expect(json[:ai_configurations]).to be_an(Array)
    end

    it 'includes enabled configurations' do
      subject
      config_keys = json[:ai_configurations].pluck(:key)
      expect(config_keys).to include(enabled_config.key, another_enabled_config.key)
    end

    it 'excludes disabled configurations' do
      subject
      config_keys = json[:ai_configurations].pluck(:key)
      expect(config_keys).not_to include(disabled_config.key)
    end

    it 'returns configurations ordered by display_name' do
      subject
      display_names = json[:ai_configurations].pluck(:display_name)
      expect(display_names).to eq(['A Config', 'C Config'])
    end

    it 'returns configuration with all required fields' do
      subject
      config = json[:ai_configurations].first
      expect(config).to have_key(:key)
      expect(config).to have_key(:value)
      expect(config).to have_key(:value_type)
      expect(config).to have_key(:display_name)
      expect(config).to have_key(:description)
      expect(config).to have_key(:enabled)
      expect(config).to have_key(:reference_type)
      expect(config).to have_key(:created_at)
      expect(config).to have_key(:updated_at)
    end
  end

  context 'when authenticated as regular user' do
    include_context 'with authenticated regular user via JWT'

    it 'returns forbidden status' do
      subject
      expect(response).to have_http_status(:forbidden)
    end

    it 'returns error message' do
      subject
      expect(json[:errors]).to be_present
      expect(json[:errors].first[:message]).to be_present
    end
  end

  context 'when not authenticated' do
    let(:auth_headers) { {} }

    it 'returns unauthorized status' do
      subject
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns error message' do
      subject
      expect(json[:errors]).to be_present
      expect(json[:errors].first[:message]).to be_present
    end
  end

  context 'when authenticated with invalid token' do
    let(:auth_headers) { { 'Authorization' => 'Bearer invalid_token' } }

    it 'returns unauthorized status' do
      subject
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns error message' do
      subject
      expect(json[:errors]).to be_present
      expect(json[:errors].first[:message]).to be_present
    end
  end
end
