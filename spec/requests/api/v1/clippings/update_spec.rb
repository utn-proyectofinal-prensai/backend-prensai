# frozen_string_literal: true

describe 'PUT /api/v1/clippings/:id' do
  subject(:request_update) { put api_v1_clipping_path(clipping.id), params:, headers: auth_headers, as: :json }

  include_context 'with authenticated admin user via JWT'

  let(:topic) { create(:topic) }
  let(:news) { create_list(:news, 2) }
  let!(:clipping) { create(:clipping, topic:, news_ids: [news.first.id]) }

  let(:valid_params) do
    {
      clipping: {
        name: 'Updated Summary',
        period_start: Date.current,
        period_end: Date.current + 2.days,
        topic_id: topic.id,
        news_ids: news.map(&:id)
      }
    }
  end

  let(:invalid_params) do
    {
      clipping: {
        name: '',
        period_start: Date.current + 5.days,
        period_end: Date.current,
        topic_id: nil
      }
    }
  end

  context 'with valid parameters' do
    let(:params) { valid_params }

    it 'returns ok status' do
      request_update
      expect(response).to have_http_status(:ok)
    end

    it 'updates the clipping attributes', :aggregate_failures do
      request_update
      expect(json[:name]).to eq('Updated Summary')
      expect(json[:topic_id]).to eq(topic.id)
      expect(json[:news_ids]).to match_array(news.map(&:id))
    end
  end

  context 'with invalid parameters' do
    let(:params) { invalid_params }

    it 'returns unprocessable entity' do
      request_update
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'does not change the clipping' do
      original_name = clipping.name
      request_update
      expect(clipping.reload.name).to eq(original_name)
    end
  end
end
