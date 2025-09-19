# frozen_string_literal: true

describe 'PUT api/v1/news/:id' do
  let(:news) { create(:news) }

  subject(:perform_request) do
    put api_v1_news_path(news), params: params, headers: auth_headers, as: :json
  end

  context 'when authenticated as admin user' do
    include_context 'with authenticated admin user via JWT'

    let(:new_topic) { create(:topic, name: 'Updated Topic') }
    let(:new_mentions) { create_list(:mention, 2) }
    let(:params) do
      {
        news: {
          title: 'Updated title',
          publication_type: 'opinion',
          valuation: 'negative',
          political_factor: 'nacional',
          topic_id: new_topic.id,
          mention_ids: new_mentions.map(&:id)
        }
      }
    end

    it 'returns a successful response' do
      perform_request
      expect(response).to have_http_status(:ok)
    end

    it 'updates the news attributes', :aggregate_failures do
      perform_request
      news.reload
      expect(news.title).to eq('Updated title')
      expect(news.valuation).to eq('negative')
      expect(news.political_factor).to eq('nacional')
      expect(news.topic_id).to eq(new_topic.id)
      expect(news.mentions.pluck(:id)).to match_array(new_mentions.map(&:id))
    end

    it 'assigns the current user as reviewer' do
      perform_request
      expect(news.reload.reviewer_id).to eq(admin_user.id)
    end

    it 'returns the updated news payload', :aggregate_failures do
      perform_request
      expect(json[:id]).to eq(news.id)
      expect(json[:title]).to eq('Updated title')
      expect(json[:reviewer][:id]).to eq(admin_user.id)
      expect(json[:topic][:id]).to eq(new_topic.id)
      expect(json[:mentions].map { |mention| mention[:id] }).to match_array(new_mentions.map(&:id))
    end
  end

  context 'when authenticated as regular user' do
    include_context 'with authenticated regular user via JWT'

    let(:new_topic) { create(:topic, name: 'Regular Reviewer Topic') }
    let(:params) do
      {
        news: {
          valuation: 'positive',
          topic_id: new_topic.id
        }
      }
    end

    it 'updates the news and assigns the reviewer' do
      perform_request
      news.reload
      expect(news.valuation).to eq('positive')
      expect(news.topic_id).to eq(new_topic.id)
      expect(news.reviewer_id).to eq(regular_user.id)
    end
  end

  context 'when the news does not exist' do
    include_context 'with authenticated admin user via JWT'

    let(:params) do
      {
        news: {
          valuation: 'neutral'
        }
      }
    end

    subject(:perform_request) do
      put api_v1_news_path(-1), params: params, headers: auth_headers, as: :json
    end

    it 'returns not found status' do
      perform_request
      expect(response).to have_http_status(:not_found)
    end
  end

  context 'when news params are missing' do
    include_context 'with authenticated admin user via JWT'

    let(:params) { {} }

    it 'returns bad request status' do
      perform_request
      expect(response).to have_http_status(:bad_request)
    end
  end

  context 'when not authenticated' do
    let(:auth_headers) { {} }
    let(:params) do
      {
        news: {
          valuation: 'neutral'
        }
      }
    end

    it 'returns unauthorized status' do
      perform_request
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'when authenticated with invalid token' do
    let(:auth_headers) { { 'Authorization' => 'Bearer invalid_token' } }
    let(:params) do
      {
        news: {
          valuation: 'positive'
        }
      }
    end

    it 'returns unauthorized status' do
      perform_request
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
