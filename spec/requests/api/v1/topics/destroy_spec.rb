# frozen_string_literal: true

describe 'DELETE api/v1/topics/:id' do
  let!(:topic) { create(:topic) }

  context 'when authenticated as admin user' do
    include_context 'with authenticated admin user via JWT'

    context 'when destroying an existing topic without dependencies' do
      subject { delete "/api/v1/topics/#{topic.id}", headers: auth_headers }

      it 'returns no content status' do
        subject
        expect(response).to have_http_status(:no_content)
      end

      it 'destroys the topic' do
        expect { subject }.to change(Topic, :count).by(-1)
        expect { topic.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'returns empty body' do
        subject
        expect(response.body).to be_empty
      end
    end

    context 'when destroying a topic with dependent news (restricted)' do
      subject { delete "/api/v1/topics/#{restricted_topic.id}", headers: auth_headers }

      let!(:restricted_topic) { create(:topic) }

      before do
        create(:news, topic: restricted_topic)
      end

      it 'returns conflict status' do
        subject
        expect(response).to have_http_status(:conflict)
      end

      it 'does not destroy the topic' do
        expect { subject }.not_to change(Topic, :count)
        expect(restricted_topic.reload).to be_present
      end

      it 'returns error message' do
        subject
        expect(json[:errors]).to be_present
        expect(json[:errors].first[:message]).to be_present
      end
    end

    context 'when record is not found' do
      subject { delete '/api/v1/topics/999999', headers: auth_headers }

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
  end

  context 'when authenticated as regular user' do
    include_context 'with authenticated regular user via JWT'

    context 'when destroying an existing topic' do
      subject { delete "/api/v1/topics/#{topic.id}", headers: auth_headers }

      it 'returns no content status' do
        subject
        expect(response).to have_http_status(:no_content)
      end

      it 'destroys the topic' do
        expect { subject }.to change(Topic, :count).by(-1)
      end
    end

    context 'when destroying a topic with dependent news (restricted)' do
      subject { delete "/api/v1/topics/#{restricted_topic.id}", headers: auth_headers }

      let!(:restricted_topic) { create(:topic) }

      before do
        create(:news, topic: restricted_topic)
      end

      it 'returns conflict status' do
        subject
        expect(response).to have_http_status(:conflict)
      end

      it 'does not destroy the topic' do
        expect { subject }.not_to change(Topic, :count)
      end
    end
  end

  context 'when not authenticated' do
    subject { delete "/api/v1/topics/#{topic.id}", headers: auth_headers }

    let(:auth_headers) { {} }

    it 'returns unauthorized status' do
      subject
      expect(response).to have_http_status(:unauthorized)
    end

    it 'does not destroy the topic' do
      expect { subject }.not_to change(Topic, :count)
      expect(topic.reload).to be_present
    end

    it 'returns error message' do
      subject
      expect(json[:errors]).to be_present
      expect(json[:errors].first[:message]).to be_present
    end
  end

  context 'when authenticated with invalid token' do
    subject { delete "/api/v1/topics/#{topic.id}", headers: auth_headers }

    let(:auth_headers) { { 'Authorization' => 'Bearer invalid_token' } }

    it 'returns unauthorized status' do
      subject
      expect(response).to have_http_status(:unauthorized)
    end

    it 'does not destroy the topic' do
      expect { subject }.not_to change(Topic, :count)
      expect(topic.reload).to be_present
    end

    it 'returns error message' do
      subject
      expect(json[:errors]).to be_present
      expect(json[:errors].first[:message]).to be_present
    end
  end
end
