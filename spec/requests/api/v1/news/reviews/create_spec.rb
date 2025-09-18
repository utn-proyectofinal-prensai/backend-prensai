# frozen_string_literal: true

describe 'POST /api/v1/news/:news_id/reviews' do
  let(:topic) { create(:topic) }

  context 'as admin user' do
    include_context 'with authenticated admin user via JWT'

    subject(:make_request) do
      post api_v1_news_reviews_path(news), params:, headers: auth_headers, as: :json
    end

    let(:news) do
      create(
        :news,
        topic: topic,
        valuation: 'neutral',
        publication_type: 'análisis',
        political_factor: 'regional',
        creator: admin_user
      )
    end

    context 'with a valid payload' do
      let(:params) do
        {
          review: {
            valuation: 'positive',
            political_factor: 'nacional',
            topic_id: topic.id,
            notes: 'Revisión manual'
          }
        }
      end

      it 'updates the news and records the review history' do
        expect { make_request }.to change(NewsReview, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(json[:news][:id]).to eq(news.id)
      expect(json[:news][:valuation]).to eq('positive')
      expect(json[:news][:reviewer][:id]).to eq(admin_user.id)
      expect(json[:news][:reviewer][:reviewed_at]).to be_present

      latest_review = json[:news][:reviews].first
      expect(latest_review[:changeset]['valuation']['before']).to eq('neutral')
      expect(latest_review[:changeset]['valuation']['after']).to eq('positive')
      expect(latest_review[:reviewer][:id]).to eq(admin_user.id)
      end
    end

    context 'when updating mentions as part of the review' do
      let(:existing_mention) { create(:mention) }
      let(:another_mention) { create(:mention) }
      let(:params) do
        {
          review: {
            mention_ids: [existing_mention.id, another_mention.id]
          }
        }
      end

      it 'replaces mentions and stores the change history' do
        news.mentions << existing_mention

        make_request

        expect(response).to have_http_status(:created)
        expect(json[:news][:mentions].map { |mention| mention[:id] }).to match_array([existing_mention.id, another_mention.id])

        mention_history = json[:review][:changeset]['mention_ids']
        expect(mention_history['before']).to match_array([existing_mention.id])
        expect(mention_history['after']).to match_array([existing_mention.id, another_mention.id])
      end
    end

    context 'with invalid mentions' do
      let(:params) do
        {
          review: {
            mention_ids: [999_999]
          }
        }
      end

      it 'returns an error response' do
        expect { make_request }.not_to change(NewsReview, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json[:errors].first[:message]).to include('no son válidas')
      end
    end
  end

  context 'as regular user' do
    include_context 'with authenticated regular user via JWT'

    subject(:make_request) do
      post api_v1_news_reviews_path(news), params:, headers: auth_headers, as: :json
    end

    let(:news) { create(:news, topic:, valuation: 'neutral', creator: regular_user) }
    let(:params) do
      {
        review: {
          valuation: 'negative'
        }
      }
    end

    it 'allows submitting a review' do
      expect { make_request }.to change(NewsReview, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(json[:news][:reviewer][:id]).to eq(regular_user.id)
      expect(json[:news][:reviewer][:reviewed_at]).to be_present
    end
  end

  context 'when unauthenticated' do
    let(:news) { create(:news, topic:) }
    let(:params) { { review: { valuation: 'positive' } } }

    it 'returns unauthorized status' do
      post api_v1_news_reviews_path(news), params:, as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
