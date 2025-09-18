# frozen_string_literal: true

describe 'GET /api/v1/news/:id' do
  include_context 'with authenticated admin user via JWT'

  subject(:make_request) do
    get api_v1_news_path(news), headers: auth_headers, as: :json
  end

  let(:topic) { create(:topic) }
  let(:news) do
    create(:news, :with_reviewer, topic: topic, creator: admin_user, reviewer: admin_user, notes: 'Initial review')
  end

  before do
    create(:news_review, news: news, reviewer: admin_user, notes: 'Second review', reviewed_at: 1.day.ago)
  end

  it 'returns the news detail with full review history' do
    make_request

    expect(response).to have_http_status(:success)
    expect(json[:news][:id]).to eq(news.id)
    expect(json[:news][:reviewer][:id]).to eq(admin_user.id)
    expect(json[:news][:reviewer][:reviewed_at]).to be_present
    expect(json[:news][:reviews].size).to eq(2)

    first_review = json[:news][:reviews].first
    expect(first_review[:notes]).to eq('Initial review')
  end

  context 'when unauthenticated' do
    let(:auth_headers) { {} }

    it 'returns unauthorized status' do
      make_request
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
