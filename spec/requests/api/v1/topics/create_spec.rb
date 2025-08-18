# frozen_string_literal: true

describe 'POST api/v1/topics' do
  subject { post api_v1_topics_path, params: params, headers: auth_headers, as: :json }

  let(:valid_params) do
    {
      topic: {
        name: 'New Topic',
        description: 'A description for the new topic',
        enabled: true
      }
    }
  end

  let(:invalid_params) do
    {
      topic: {
        name: '',
        description: 'Description without name'
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

      it 'creates a new topic' do
        expect { subject }.to change(Topic, :count).by(1)
      end

      it 'returns the created topic data', :aggregate_failures do
        subject
        expect(json[:name]).to eq('New Topic')
        expect(json[:description]).to eq('A description for the new topic')
        expect(json[:enabled]).to be true
        expect(json[:crisis]).to be false
        expect(json[:id]).to be_present
        expect(json[:created_at]).to be_present
        expect(json[:updated_at]).to be_present
      end

      it 'sets the correct topic attributes' do
        subject
        topic = Topic.last
        expect(topic.name).to eq('New Topic')
        expect(topic.description).to eq('A description for the new topic')
        expect(topic.enabled).to be true
        expect(topic.crisis).to be false
      end
    end

    context 'with minimal valid parameters' do
      let(:params) do
        {
          topic: {
            name: 'Minimal Topic'
          }
        }
      end

      it 'creates a topic with defaults' do
        expect { subject }.to change(Topic, :count).by(1)
        expect(response).to have_http_status(:created)
      end

      it 'sets default values correctly', :aggregate_failures do
        subject
        topic = Topic.last
        expect(topic.name).to eq('Minimal Topic')
        expect(topic.description).to be_nil
        expect(topic.enabled).to be true # default value
        expect(topic.crisis).to be false # default value
      end
    end

    context 'with enabled set to false' do
      let(:params) do
        {
          topic: {
            name: 'Disabled Topic',
            description: 'This topic is disabled',
            enabled: false
          }
        }
      end

      it 'creates a disabled topic' do
        subject
        topic = Topic.last
        expect(topic.enabled).to be false
      end
    end

    context 'with invalid parameters' do
      let(:params) { invalid_params }

      it 'returns unprocessable entity status' do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not create a topic' do
        expect { subject }.not_to change(Topic, :count)
      end

      it 'returns validation errors', :aggregate_failures do
        subject
        expect(json[:errors]).to be_present
        expect(json[:errors].first).to have_key(:name)
      end
    end

    context 'with duplicate name' do
      before { create(:topic, name: 'Duplicate Topic') }

      let(:params) do
        {
          topic: {
            name: 'Duplicate Topic',
            description: 'This will fail'
          }
        }
      end

      it 'returns unprocessable entity status' do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not create a topic' do
        expect { subject }.not_to change(Topic, :count)
      end

      it 'returns uniqueness validation error' do
        subject
        expect(json[:errors].first[:name]).to include(I18n.t('errors.messages.taken'))
      end
    end

    context 'with missing topic parameter' do
      let(:params) { {} }

      it 'returns bad request status' do
        subject
        expect(response).to have_http_status(:bad_request)
      end

      it 'does not create a topic' do
        expect { subject }.not_to change(Topic, :count)
      end
    end

    context 'with extra parameters' do
      let(:params) do
        {
          topic: {
            name: 'Valid Topic',
            description: 'Valid description',
            crisis: true, # This should be ignored
            unauthorized_field: 'should be ignored'
          }
        }
      end

      it 'creates the topic ignoring extra parameters' do
        expect { subject }.to change(Topic, :count).by(1)
        expect(response).to have_http_status(:created)
      end

      it 'only uses permitted parameters', :aggregate_failures do
        subject
        topic = Topic.last
        expect(topic.name).to eq('Valid Topic')
        expect(topic.description).to eq('Valid description')
        expect(topic.crisis).to be false # Should use default, not the passed value
        expect(topic).not_to respond_to(:unauthorized_field)
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

    it 'creates a new topic' do
      expect { subject }.to change(Topic, :count).by(1)
    end

    it 'returns the created topic data' do
      subject
      expect(json[:name]).to eq('New Topic')
      expect(json[:description]).to eq('A description for the new topic')
    end
  end

  context 'when not authenticated' do
    let(:auth_headers) { {} }
    let(:params) { valid_params }

    it 'returns unauthorized status' do
      subject
      expect(response).to have_http_status(:unauthorized)
    end

    it 'does not create a topic' do
      expect { subject }.not_to change(Topic, :count)
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

    it 'does not create a topic' do
      expect { subject }.not_to change(Topic, :count)
    end

    it 'returns error message' do
      subject
      expect(json[:errors]).to be_present
      expect(json[:errors].first[:message]).to be_present
    end
  end
end
