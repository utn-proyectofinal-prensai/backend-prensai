# frozen_string_literal: true

require 'rails_helper'

describe 'PATCH api/v1/ai_configurations/:key' do
  subject do
    patch api_v1_ai_configuration_path(config.key), params: { ai_configuration: update_params }, headers: auth_headers,
                                                    as: :json
  end

  let!(:config) { create(:ai_configuration, enabled: true, value: 'original_value') }
  let(:update_params) { { enabled: false, value: 'updated_value' } }

  context 'when authenticated as admin user' do
    include_context 'with authenticated admin user via JWT'

    context 'with valid parameters' do
      it 'returns a successful response' do
        subject
        expect(response).to have_http_status(:success)
      end

      it 'updates the configuration' do
        subject
        config.reload
        expect(config.enabled).to be false
        expect(config.value).to eq('updated_value')
      end

      it 'returns the updated configuration data' do
        subject
        expect(json[:key]).to eq(config.key)
        expect(json[:enabled]).to be false
        expect(json[:value]).to eq('updated_value')
      end

      context 'when updating only enabled status' do
        let(:update_params) { { enabled: false } }

        it 'updates only the enabled field' do
          subject
          config.reload
          expect(config.enabled).to be false
          expect(config.value).to eq('original_value')
        end
      end

      context 'when updating only value' do
        let(:update_params) { { value: 'new_value' } }

        it 'updates only the value field' do
          subject
          config.reload
          expect(config.enabled).to be true
          expect(config.value).to eq('new_value')
        end
      end

      context 'when updating array value' do
        let!(:config) { create(:ai_configuration, :array_type, value: %w[item1 item2]) }
        let(:update_params) { { value: %w[new_item1 new_item2 new_item3] } }

        it 'updates the array value' do
          subject
          config.reload
          expect(config.value).to eq(%w[new_item1 new_item2 new_item3])
        end
      end

      context 'when updating reference value' do
        let!(:config) { create(:ai_configuration, :reference_type, value: 123) }
        let(:update_params) { { value: 456 } }

        it 'updates the reference value' do
          subject
          config.reload
          expect(config.value).to eq(456)
        end
      end
    end

    context 'with invalid parameters' do
      context 'when value type does not match value' do
        let!(:config) { create(:ai_configuration, value_type: 'string', value: 'test') }
        let(:update_params) { { value: 123 } } # Integer for string type

        it 'returns unprocessable entity status' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'does not update the configuration' do
          subject
          config.reload
          expect(config.value).to eq('test')
        end
      end

      context 'when value type does not match array value' do
        let!(:config) { create(:ai_configuration, :array_type) }
        let(:update_params) { { value: 'not an array' } }

        it 'returns unprocessable entity status' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context 'when configuration does not exist' do
      subject do
        patch api_v1_ai_configuration_path('non_existing_key'), params: { ai_configuration: update_params },
                                                                headers: auth_headers, as: :json
      end

      it 'returns not found status' do
        subject
        expect(response).to have_http_status(:not_found)
      end
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

    it 'does not update the configuration' do
      subject
      config.reload
      expect(config.enabled).to be true
      expect(config.value).to eq('original_value')
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
