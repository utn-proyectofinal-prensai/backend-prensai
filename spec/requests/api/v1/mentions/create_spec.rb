# frozen_string_literal: true

describe 'POST api/v1/mentions' do
  subject { post api_v1_mentions_path, params: params, headers: auth_headers, as: :json }

  let(:valid_params) do
    {
      mention: {
        name: 'New Mention'
      }
    }
  end

  let(:invalid_params) do
    {
      mention: {
        name: ''
      }
    }
  end

  context 'when authenticated as admin user' do
    include_context 'with authenticated admin user via JWT'

    context 'with valid parameters' do
      let(:params) { valid_params }

      it 'returns a successful response' do
        subject
        expect(response).to have_http_status(:created)
      end

      it 'creates a new mention' do
        expect { subject }.to change(Mention, :count).by(1)
      end

      it 'returns the created mention data', :aggregate_failures do
        subject
        expect(json[:name]).to eq('New Mention')
        expect(json[:id]).to be_present
        expect(json[:created_at]).to be_present
        expect(json[:updated_at]).to be_present
      end
    end

    context 'with invalid parameters' do
      let(:params) { invalid_params }

      it 'returns unprocessable entity status' do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not create a mention' do
        expect { subject }.not_to change(Mention, :count)
      end

      it 'returns validation errors', :aggregate_failures do
        subject
        expect(json[:errors]).to be_present
        expect(json[:errors].first).to have_key(:name)
      end
    end

    context 'with duplicate name' do
      before { create(:mention, name: 'Duplicate Name') }

      let(:params) do
        {
          mention: {
            name: 'Duplicate Name'
          }
        }
      end

      it 'returns unprocessable entity status' do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not create a mention' do
        expect { subject }.not_to change(Mention, :count)
      end
    end

    context 'with missing mention parameter' do
      let(:params) { {} }

      it 'returns bad request status' do
        subject
        expect(response).to have_http_status(:bad_request)
      end

      it 'does not create a mention' do
        expect { subject }.not_to change(Mention, :count)
      end
    end
  end

  context 'when authenticated as regular user' do
    include_context 'with authenticated regular user via JWT'
    let(:params) { valid_params }

    it 'returns a successful response' do
      subject
      expect(response).to have_http_status(:created)
    end

    it 'creates a new mention' do
      expect { subject }.to change(Mention, :count).by(1)
    end

    it 'returns the created mention data' do
      subject
      expect(json[:name]).to eq('New Mention')
    end
  end

  context 'when not authenticated' do
    let(:auth_headers) { {} }
    let(:params) { valid_params }

    it 'returns unauthorized status' do
      subject
      expect(response).to have_http_status(:unauthorized)
    end

    it 'does not create a mention' do
      expect { subject }.not_to change(Mention, :count)
    end

    it 'returns error message' do
      subject
      expect(json[:errors]).to be_present
      expect(json[:errors].first[:message]).to be_present
    end
  end

  context 'when authenticated with invalid token' do
    let(:auth_headers) { { 'Authorization' => 'Bearer invalid_token' } }
    let(:params) { valid_params }

    it 'returns unauthorized status' do
      subject
      expect(response).to have_http_status(:unauthorized)
    end

    it 'does not create a mention' do
      expect { subject }.not_to change(Mention, :count)
    end

    it 'returns error message' do
      subject
      expect(json[:errors]).to be_present
      expect(json[:errors].first[:message]).to be_present
    end
  end
end
