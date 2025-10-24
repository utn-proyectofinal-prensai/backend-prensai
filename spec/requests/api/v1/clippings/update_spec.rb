# frozen_string_literal: true

describe 'PUT /api/v1/clippings/:id' do
  subject(:request_update) { put api_v1_clipping_path(clipping.id), params:, headers: auth_headers, as: :json }

  let(:topic) { create(:topic) }
  let(:news) { create_list(:news, 2, topic: topic, date: Date.current) }

  let(:valid_params) do
    {
      clipping: {
        name: 'Updated Summary',
        start_date: Date.current,
        end_date: Date.current + 2.days,
        topic_id: topic.id,
        news_ids: news.map(&:id)
      }
    }
  end

  let(:invalid_params) do
    {
      clipping: {
        name: '',
        start_date: Date.current + 5.days,
        end_date: Date.current,
        topic_id: nil
      }
    }
  end

  context 'when authenticated as admin user' do
    include_context 'with authenticated admin user via JWT'

    let(:clipping) { create(:clipping, topic:, news_ids: [news.first.id]) }
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

  context 'when authenticated as the creator' do
    include_context 'with authenticated regular user via JWT'

    let(:clipping) { create(:clipping, creator: regular_user, topic:, news_ids: [news.first.id]) }
    let(:params) { valid_params }

    it 'updates the clipping', :aggregate_failures do
      request_update
      expect(response).to have_http_status(:ok)
      expect(json[:name]).to eq('Updated Summary')
    end
  end

  context 'when authenticated as a different regular user' do
    include_context 'with authenticated regular user via JWT'

    let(:clipping) { create(:clipping) }
    let(:params) { valid_params }

    it 'returns forbidden status' do
      request_update
      expect(response).to have_http_status(:forbidden)
    end

    it 'does not update the clipping' do
      original_name = clipping.name
      request_update
      expect(clipping.reload.name).to eq(original_name)
    end
  end
end
