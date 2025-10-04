# frozen_string_literal: true

describe 'POST /api/v1/clippings' do
  subject(:request_create) { post api_v1_clippings_path, params:, headers: auth_headers, as: :json }

  include_context 'with authenticated admin user via JWT'

  let(:topic) { create(:topic) }
  let(:news) { create_list(:news, 2) }

  let(:valid_params) do
    {
      clipping: {
        name: 'Weekly Summary',
        start_date: Date.current,
        end_date: Date.current + 1.day,
        topic_id: topic.id,
        news_ids: news.map(&:id)
      }
    }
  end

  let(:invalid_params) do
    {
      clipping: {
        name: '',
        start_date: nil,
        end_date: nil,
        topic_id: nil,
        news_ids: []
      }
    }
  end

  context 'with valid parameters' do
    let(:params) { valid_params }

    it 'returns created status' do
      request_create
      expect(response).to have_http_status(:created)
    end

    it 'creates a clipping' do
      expect { request_create }.to change(Clipping, :count).by(1)
    end

    it 'returns the created clipping data', :aggregate_failures do
      request_create
      expect(json[:id]).to be_present
      expect(json[:name]).to eq('Weekly Summary')
      expect(json[:topic_id]).to eq(topic.id)
      expect(json[:news_ids]).to match_array(news.map(&:id))
      expect(json[:creator]).to include(:id, :name)
    end
  end

  context 'with invalid parameters' do
    let(:params) { invalid_params }

    it 'returns unprocessable entity' do
      request_create
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'does not create a clipping' do
      expect { request_create }.not_to change(Clipping, :count)
    end

    it 'returns validation errors' do
      request_create
      expect(json[:errors]).to be_present
    end
  end
end
