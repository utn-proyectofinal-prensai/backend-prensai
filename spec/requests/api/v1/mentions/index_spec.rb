# frozen_string_literal: true

describe 'GET api/v1/mentions' do
  subject { get api_v1_mentions_path, headers: auth_headers, as: :json }

  let!(:mention_zebra) { create(:mention, name: 'Zebra') }
  let!(:mention_apple) { create(:mention, name: 'Apple', enabled: false) }
  let!(:mention_mango) { create(:mention, name: 'Mango') }

  context 'when authenticated as admin user' do
    include_context 'with authenticated admin user via JWT'

    it 'returns a successful response' do
      subject
      expect(response).to have_http_status(:success)
    end

    it 'returns all mentions ordered alphabetically', :aggregate_failures do
      subject
      expect(json[:mentions]).to be_an(Array)
      expect(json[:mentions].size).to eq(3)

      # Verify alphabetical order
      mention_names = json[:mentions].pluck(:name)
      expect(mention_names).to eq(%w[Apple Mango Zebra])
    end

    it 'returns correct mention data structure', :aggregate_failures do
      subject
      mention = json[:mentions].first

      expect(mention).to have_key(:id)
      expect(mention).to have_key(:name)
      expect(mention).to have_key(:created_at)
      expect(mention).to have_key(:updated_at)
    end

    context 'with mentions associated to news' do
      let!(:news_item) { create(:news) }

      before do
        mention_apple.news << news_item
      end

      it 'returns mentions regardless of news associations' do
        subject
        mention_ids = json[:mentions].pluck(:id)
        expect(mention_ids).to include(mention_apple.id, mention_mango.id, mention_zebra.id)
      end
    end

    context 'with empty mentions list' do
      before do
        Mention.destroy_all
      end

      it 'returns empty array' do
        subject
        expect(json[:mentions]).to be_an(Array)
        expect(json[:mentions]).to be_empty
      end
    end
  end

  context 'when authenticated as regular user' do
    include_context 'with authenticated regular user via JWT'

    it 'returns a successful response' do
      subject
      expect(response).to have_http_status(:success)
    end

    it 'returns mentions data for regular users', :aggregate_failures do
      subject
      expect(json[:mentions]).to be_an(Array)
      expect(json[:mentions].size).to eq(3)
    end

    it 'applies the same ordering as for admin users' do
      subject
      mention_names = json[:mentions].pluck(:name)
      expect(mention_names).to eq(%w[Apple Mango Zebra])
    end
  end

  context 'when sending filtering params' do
    include_context 'with authenticated admin user via JWT'

    context 'with enabled=true filter' do
      subject { get api_v1_mentions_path(enabled: 'true'), headers: auth_headers, as: :json }

      it 'returns only enabled mentions' do
        subject
        expect(json[:mentions].size).to eq(2)
      end

      it 'all returned mentions are enabled' do
        subject
        enabled_states = json[:mentions].pluck(:enabled)
        expect(enabled_states).to all(be true)
      end
    end

    context 'with enabled=false filter' do
      subject { get api_v1_mentions_path(enabled: 'false'), headers: auth_headers, as: :json }

      it 'returns only disabled mentions' do
        subject
        expect(json[:mentions].size).to eq(1)
        expect(json[:mentions].first[:enabled]).to be false
      end
    end

    context 'with invalid filter params' do
      subject { get api_v1_mentions_path(invalid_param: 'value'), headers: auth_headers, as: :json }

      it 'ignores invalid params and returns all mentions' do
        subject
        expect(json[:mentions].size).to eq(3)
      end
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
