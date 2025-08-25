# frozen_string_literal: true

describe 'PUT/PATCH api/v1/topics/:id' do
  let(:topic) { create(:topic, name: 'Original Topic', description: 'Original Description') }

  context 'when authenticated as admin user' do
    include_context 'with authenticated admin user via JWT'

    context 'with valid parameters' do
      subject { put "/api/v1/topics/#{topic.id}", params: params, headers: auth_headers, as: :json }

      let(:params) do
        {
          topic: {
            name: 'Updated Topic'
          }
        }
      end

      it 'returns a successful response' do
        subject
        expect(response).to have_http_status(:success)
      end

      it 'updates the topic' do
        subject
        expect(topic.reload.name).to eq('Updated Topic')
      end

      it 'returns the updated topic data', :aggregate_failures do
        subject
        expect(json[:id]).to eq(topic.id)
        expect(json[:name]).to eq('Updated Topic')
        expect(json[:description]).to eq('Original Description')
        expect(json[:enabled]).to be(true)
        expect(json[:crisis]).to be(false)
        expect(json[:created_at]).to be_present
        expect(json[:updated_at]).to be_present
      end
    end

    context 'with invalid parameters' do
      subject { put "/api/v1/topics/#{topic.id}", params: params, headers: auth_headers, as: :json }

      let(:params) do
        {
          topic: {
            name: ''
          }
        }
      end

      it 'returns unprocessable entity status' do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not update the topic' do
        original_name = topic.name
        subject
        expect(topic.reload.name).to eq(original_name)
      end

      it 'returns validation errors' do
        subject
        expect(json[:errors]).to be_present
      end
    end

    context 'when topic is not found' do
      subject { put '/api/v1/topics/99999', params: params, headers: auth_headers, as: :json }

      let(:params) do
        {
          topic: {
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

    context 'with missing topic parameter' do
      subject { put "/api/v1/topics/#{topic.id}", params: params, headers: auth_headers, as: :json }

      let(:params) { {} }

      it 'returns bad request status' do
        subject
        expect(response).to have_http_status(:bad_request)
      end

      it 'does not update the topic' do
        original_name = topic.name
        subject
        expect(topic.reload.name).to eq(original_name)
      end

      it 'returns error message' do
        subject
        expect(json[:errors]).to be_present
        expect(json[:errors].first[:message]).to be_present
      end
    end
  end

  context 'when authenticated as regular user' do
    subject { put "/api/v1/topics/#{topic.id}", params: params, headers: auth_headers, as: :json }

    include_context 'with authenticated regular user via JWT'

    let(:params) do
      {
        topic: {
          name: 'Regular User Update'
        }
      }
    end

    it 'returns a successful response' do
      subject
      expect(response).to have_http_status(:success)
    end

    it 'updates the topic' do
      subject
      expect(topic.reload.name).to eq('Regular User Update')
    end

    it 'returns the updated topic data' do
      subject
      expect(json[:name]).to eq('Regular User Update')
    end
  end

  context 'when not authenticated' do
    subject { put "/api/v1/topics/#{topic.id}", params: params, headers: auth_headers, as: :json }

    let(:auth_headers) { {} }
    let(:params) do
      {
        topic: {
          name: 'Unauthorized Attempt'
        }
      }
    end

    it 'returns unauthorized status' do
      subject
      expect(response).to have_http_status(:unauthorized)
    end

    it 'does not update the topic' do
      original_name = topic.name
      subject
      expect(topic.reload.name).to eq(original_name)
    end

    it 'returns error message' do
      subject
      expect(json[:errors]).to be_present
      expect(json[:errors].first[:message]).to be_present
    end
  end

  context 'when authenticated with invalid token' do
    subject { put "/api/v1/topics/#{topic.id}", params: params, headers: auth_headers, as: :json }

    let(:auth_headers) { { 'Authorization' => 'Bearer invalid_token' } }
    let(:params) do
      {
        topic: {
          name: 'Invalid Token Attempt'
        }
      }
    end

    it 'returns unauthorized status' do
      subject
      expect(response).to have_http_status(:unauthorized)
    end

    it 'does not update the topic' do
      original_name = topic.name
      subject
      expect(topic.reload.name).to eq(original_name)
    end

    it 'returns error message' do
      subject
      expect(json[:errors]).to be_present
      expect(json[:errors].first[:message]).to be_present
    end
  end
end
