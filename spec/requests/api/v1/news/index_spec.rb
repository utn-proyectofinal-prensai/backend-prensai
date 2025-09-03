# frozen_string_literal: true

describe 'GET api/v1/news' do
  subject { get api_v1_news_index_path, headers: auth_headers, as: :json }

  let!(:topic) { create(:topic) }
  let!(:creator) { create(:user) }
  let!(:reviewer) { create(:user) }
  let!(:recent_news) do
    create(:news, title: 'Recent News', topic: topic, creator: creator, reviewer: reviewer, created_at: 1.day.ago)
  end
  let!(:old_news) do
    create(:news, title: 'Old News', topic: topic, creator: creator, reviewer: reviewer, created_at: 1.week.ago)
  end

  context 'when authenticated as admin user' do
    include_context 'with authenticated admin user via JWT'

    it 'returns a successful response' do
      subject
      expect(response).to have_http_status(:success)
    end

    it 'returns all news ordered by date descending', :aggregate_failures do
      subject
      expect(json[:news]).to be_an(Array)
      expect(json[:news].size).to eq(2)

      # Verify order (most recent first)
      expect(json[:news].first[:title]).to eq('Recent News')
      expect(json[:news].last[:title]).to eq('Old News')
    end

    it 'returns correct news data structure', :aggregate_failures do
      subject
      news_item = json[:news].first

      expect(news_item).to have_key(:id)
      expect(news_item).to have_key(:title)
      expect(news_item).to have_key(:publication_type)
      expect(news_item).to have_key(:date)
      expect(news_item).to have_key(:support)
      expect(news_item).to have_key(:media)
      expect(news_item).to have_key(:valuation)
      expect(news_item).to have_key(:created_at)
      expect(news_item).to have_key(:updated_at)
      expect(news_item).to have_key(:creator)
      expect(news_item).to have_key(:reviewer)
    end

    it 'includes creator and reviewer as objects', :aggregate_failures do
      subject
      news_item = json[:news].first

      expect(news_item[:creator]).to be_a(Hash)
      expect(news_item[:creator][:id]).to eq(creator.id)
      expect(news_item[:creator][:name]).to eq(creator.full_name)

      expect(news_item[:reviewer]).to be_a(Hash)
      expect(news_item[:reviewer][:id]).to eq(reviewer.id)
      expect(news_item[:reviewer][:name]).to eq(reviewer.full_name)
    end

    it 'includes pagination metadata', :aggregate_failures do
      subject
      expect(json).to have_key(:pagination)
      expect(json[:pagination]).to have_key(:count)
      expect(json[:pagination]).to have_key(:page)
      expect(json[:pagination]).to have_key(:pages)
      expect(json[:pagination]).to have_key(:next)
      expect(json[:pagination]).to have_key(:prev)
    end

    context 'with many news items' do
      before do
        create_list(:news, 10, topic: topic, creator: creator, reviewer: reviewer)
      end

      it 'paginates results correctly' do
        subject
        expect(json[:pagination][:pages]).to be 1
        expect(json[:news].size).to be <= 25 # Default pagy items per page
      end

      it 'provides next page information when applicable' do
        subject
        expect(json[:pagination][:next]).to be_present if json[:pagination][:pages] > 1
      end
    end

    context 'with news from different topics' do
      let!(:another_topic) { create(:topic) }
      let!(:news_from_another_topic) { create(:news, topic: another_topic, creator: creator, reviewer: reviewer) }

      it 'returns news from all topics' do
        subject
        news_ids = json[:news].pluck(:id)
        expect(news_ids).to include(recent_news.id, old_news.id, news_from_another_topic.id)
      end
    end

    context 'with news having different valuations' do
      before do
        create(:news, valuation: 'positive', topic: topic, creator: creator, reviewer: reviewer)
        create(:news, valuation: 'negative', topic: topic, creator: creator, reviewer: reviewer)
        create(:news, valuation: 'neutral', topic: topic, creator: creator, reviewer: reviewer)
      end

      it 'returns news with all valuations' do
        subject
        valuations = json[:news].pluck(:valuation)
        expect(valuations).to include('positive', 'negative', 'neutral')
      end
    end
  end

  context 'when authenticated as regular user' do
    include_context 'with authenticated regular user via JWT'

    it 'returns a successful response' do
      subject
      expect(response).to have_http_status(:success)
    end

    it 'returns news data for regular users', :aggregate_failures do
      subject
      expect(json[:news]).to be_an(Array)
      expect(json[:news].size).to eq(2)
    end

    it 'applies the same ordering as for admin users' do
      subject
      expect(json[:news].first[:title]).to eq('Recent News')
      expect(json[:news].last[:title]).to eq('Old News')
    end
  end

  context 'when not authenticated' do
    let(:auth_headers) { {} }

    it 'returns unauthorized status' do
      subject
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns error message' do
      subject
      expect(json[:errors]).to be_present
      expect(json[:errors].first[:message]).to be_present
    end
  end

  context 'when authenticated with invalid token' do
    let(:auth_headers) { { 'Authorization' => 'Bearer invalid_token' } }

    it 'returns unauthorized status' do
      subject
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns error message' do
      subject
      expect(json[:errors]).to be_present
      expect(json[:errors].first[:message]).to be_present
    end
  end
end
