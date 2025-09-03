# frozen_string_literal: true

describe 'DELETE api/v1/mentions/:id' do
  let!(:mention) { create(:mention) }

  context 'when authenticated as admin user' do
    include_context 'with authenticated admin user via JWT'

    context 'when destroying an existing mention without dependencies' do
      subject { delete "/api/v1/mentions/#{mention.id}", headers: auth_headers }

      it 'returns no content status' do
        subject
        expect(response).to have_http_status(:no_content)
      end

      it 'destroys the mention' do
        expect { subject }.to change(Mention, :count).by(-1)
        expect { mention.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'returns empty body' do
        subject
        expect(response.body).to be_empty
      end
    end

    context 'when destroying a mention with dependent news (restricted)' do
      subject { delete "/api/v1/mentions/#{restricted_mention.id}", headers: auth_headers }

      let!(:restricted_mention) { create(:mention, :with_news) }

      it 'returns conflict status' do
        subject
        expect(response).to have_http_status(:conflict)
      end

      it 'does not destroy the mention' do
        expect { subject }.not_to change(Mention, :count)
        expect(restricted_mention.reload).to be_present
      end

      it 'returns error message' do
        subject
        expect(json[:errors]).to be_present
        expect(json[:errors].first[:message]).to be_present
      end
    end

    context 'when record is not found' do
      subject { delete '/api/v1/mentions/999999', headers: auth_headers }

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

    context 'when destroying an existing mention' do
      subject { delete "/api/v1/mentions/#{mention.id}", headers: auth_headers }

      it 'returns no content status' do
        subject
        expect(response).to have_http_status(:no_content)
      end

      it 'destroys the mention' do
        expect { subject }.to change(Mention, :count).by(-1)
      end
    end

    context 'when destroying a mention with dependent news (restricted)' do
      subject { delete "/api/v1/mentions/#{restricted_mention.id}", headers: auth_headers }

      let!(:restricted_mention) { create(:mention, :with_news) }

      it 'returns conflict status' do
        subject
        expect(response).to have_http_status(:conflict)
      end

      it 'does not destroy the mention' do
        expect { subject }.not_to change(Mention, :count)
      end
    end
  end

  context 'when not authenticated' do
    subject { delete "/api/v1/mentions/#{mention.id}", headers: auth_headers }

    let(:auth_headers) { {} }

    it 'returns unauthorized status' do
      subject
      expect(response).to have_http_status(:unauthorized)
    end

    it 'does not destroy the mention' do
      expect { subject }.not_to change(Mention, :count)
      expect(mention.reload).to be_present
    end

    it 'returns error message' do
      subject
      expect(json[:errors]).to be_present
      expect(json[:errors].first[:message]).to be_present
    end
  end

  context 'when authenticated with invalid token' do
    subject { delete "/api/v1/mentions/#{mention.id}", headers: auth_headers }

    let(:auth_headers) { { 'Authorization' => 'Bearer invalid_token' } }

    it 'returns unauthorized status' do
      subject
      expect(response).to have_http_status(:unauthorized)
    end

    it 'does not destroy the mention' do
      expect { subject }.not_to change(Mention, :count)
      expect(mention.reload).to be_present
    end

    it 'returns error message' do
      subject
      expect(json[:errors]).to be_present
      expect(json[:errors].first[:message]).to be_present
    end
  end
end
