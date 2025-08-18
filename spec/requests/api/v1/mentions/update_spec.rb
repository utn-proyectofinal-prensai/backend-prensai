# frozen_string_literal: true

describe 'PUT/PATCH api/v1/mentions/:id' do
  let(:mention) { create(:mention, name: 'Original Name') }

  context 'when authenticated as admin user' do
    include_context 'with authenticated admin user via JWT'

    context 'with valid parameters' do
      subject { put "/api/v1/mentions/#{mention.id}", params: params, headers: auth_headers, as: :json }

      let(:params) do
        {
          mention: {
            name: 'Updated Name'
          }
        }
      end

      it 'returns a successful response' do
        subject
        expect(response).to have_http_status(:success)
      end

      it 'updates the mention' do
        subject
        expect(mention.reload.name).to eq('Updated Name')
      end

      it 'returns the updated mention data', :aggregate_failures do
        subject
        expect(json[:id]).to eq(mention.id)
        expect(json[:name]).to eq('Updated Name')
        expect(json[:enabled]).to be(true)
        expect(json[:created_at]).to be_present
        expect(json[:updated_at]).to be_present
      end
    end

    context 'with invalid parameters' do
      subject { put "/api/v1/mentions/#{mention.id}", params: params, headers: auth_headers, as: :json }

      let(:params) do
        {
          mention: {
            name: ''
          }
        }
      end

      it 'returns unprocessable entity status' do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not update the mention' do
        original_name = mention.name
        subject
        expect(mention.reload.name).to eq(original_name)
      end

      it 'returns validation errors' do
        subject
        expect(json[:errors]).to be_present
      end
    end

    context 'when mention is not found' do
      subject { put '/api/v1/mentions/99999', params: params, headers: auth_headers, as: :json }

      let(:params) do
        {
          mention: {
            name: 'Not Found Test'
          }
        }
      end

      it 'returns status 404 not found' do
        subject
        expect(response).to have_http_status(:not_found)
      end

      it 'returns error message' do
        subject
        expect(json[:errors]).to be_present
        expect(json[:errors].first[:message]).to be_present
      end
    end

    context 'with missing mention parameter' do
      subject { put "/api/v1/mentions/#{mention.id}", params: params, headers: auth_headers, as: :json }

      let(:params) { {} }

      it 'returns bad request status' do
        subject
        expect(response).to have_http_status(:bad_request)
      end

      it 'does not update the mention' do
        original_name = mention.name
        subject
        expect(mention.reload.name).to eq(original_name)
      end

      it 'returns error message' do
        subject
        expect(json[:errors]).to be_present
        expect(json[:errors].first[:message]).to be_present
      end
    end
  end

  context 'when authenticated as regular user' do
    subject { put "/api/v1/mentions/#{mention.id}", params: params, headers: auth_headers, as: :json }

    include_context 'with authenticated regular user via JWT'

    let(:params) do
      {
        mention: {
          name: 'Regular User Update'
        }
      }
    end

    it 'returns a successful response' do
      subject
      expect(response).to have_http_status(:success)
    end

    it 'updates the mention' do
      subject
      expect(mention.reload.name).to eq('Regular User Update')
    end

    it 'returns the updated mention data' do
      subject
      expect(json[:name]).to eq('Regular User Update')
    end
  end

  context 'when not authenticated' do
    subject { put "/api/v1/mentions/#{mention.id}", params: params, headers: auth_headers, as: :json }

    let(:auth_headers) { {} }
    let(:params) do
      {
        mention: {
          name: 'Unauthorized Attempt'
        }
      }
    end

    it 'returns unauthorized status' do
      subject
      expect(response).to have_http_status(:unauthorized)
    end

    it 'does not update the mention' do
      original_name = mention.name
      subject
      expect(mention.reload.name).to eq(original_name)
    end

    it 'returns error message' do
      subject
      expect(json[:errors]).to be_present
      expect(json[:errors].first[:message]).to be_present
    end
  end

  context 'when authenticated with invalid token' do
    subject { put "/api/v1/mentions/#{mention.id}", params: params, headers: auth_headers, as: :json }

    let(:auth_headers) { { 'Authorization' => 'Bearer invalid_token' } }
    let(:params) do
      {
        mention: {
          name: 'Invalid Token Attempt'
        }
      }
    end

    it 'returns unauthorized status' do
      subject
      expect(response).to have_http_status(:unauthorized)
    end

    it 'does not update the mention' do
      original_name = mention.name
      subject
      expect(mention.reload.name).to eq(original_name)
    end

    it 'returns error message' do
      subject
      expect(json[:errors]).to be_present
      expect(json[:errors].first[:message]).to be_present
    end
  end
end
