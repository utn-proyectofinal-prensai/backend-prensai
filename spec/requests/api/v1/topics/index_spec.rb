# frozen_string_literal: true

describe 'GET api/v1/topics' do
  subject { get api_v1_topics_path, headers: auth_headers, as: :json }

  let!(:topic_zebra) { create(:topic, name: 'Zebra Topic', description: 'About zebras') }
  let!(:topic_apple) { create(:topic, name: 'Apple Topic', description: 'About apples', enabled: false) }
  let!(:topic_mango) { create(:topic, name: 'Mango Topic', description: 'About mangos', crisis: true) }

  context 'when authenticated as admin user' do
    include_context 'with authenticated admin user via JWT'

    it 'returns a successful response' do
      subject
      expect(response).to have_http_status(:success)
    end

    it 'returns all topics ordered alphabetically', :aggregate_failures do
      subject
      expect(json[:topics]).to be_an(Array)
      expect(json[:topics].size).to eq(3)

      # Verify alphabetical order
      topic_names = json[:topics].pluck(:name)
      expect(topic_names).to eq(['Apple Topic', 'Mango Topic', 'Zebra Topic'])
    end

    it 'returns correct topic data structure', :aggregate_failures do
      subject
      topic = json[:topics].first

      expect(topic).to have_key(:id)
      expect(topic).to have_key(:name)
      expect(topic).to have_key(:description)
      expect(topic).to have_key(:enabled)
      expect(topic).to have_key(:crisis)
      expect(topic).to have_key(:created_at)
      expect(topic).to have_key(:updated_at)
    end

    it 'includes topics with different states', :aggregate_failures do
      subject
      enabled_states = json[:topics].pluck(:enabled)
      crisis_states = json[:topics].pluck(:crisis)

      expect(enabled_states).to include(true, false)
      expect(crisis_states).to include(true, false)
    end

    context 'with topics associated to news' do
      before { create(:news, topic: topic_mango) }

      it 'returns topics regardless of news associations' do
        subject
        topic_ids = json[:topics].pluck(:id)
        expect(topic_ids).to include(topic_apple.id, topic_mango.id, topic_zebra.id)
      end

      it 'includes topic with associated news' do
        subject
        mango_topic = json[:topics].find { |t| t[:id] == topic_mango.id }
        expect(mango_topic).to be_present
        expect(mango_topic[:name]).to eq('Mango Topic')
      end
    end

    context 'with empty topics list' do
      before do
        Topic.destroy_all
      end

      it 'returns empty array' do
        subject
        expect(json[:topics]).to be_an(Array)
        expect(json[:topics]).to be_empty
      end
    end

    context 'with topics in crisis state' do
      before do
        # Create enough negative news to trigger crisis
        create_list(:news, 6, topic: topic_zebra, valuation: 'negative')
        topic_zebra.check_crisis!
      end

      it 'includes crisis information' do
        subject
        zebra_topic = json[:topics].find { |t| t[:id] == topic_zebra.id }
        expect(zebra_topic[:crisis]).to be true
      end
    end
  end

  context 'when authenticated as regular user' do
    include_context 'with authenticated regular user via JWT'

    it 'returns a successful response' do
      subject
      expect(response).to have_http_status(:success)
    end

    it 'returns topics data for regular users', :aggregate_failures do
      subject
      expect(json[:topics]).to be_an(Array)
      expect(json[:topics].size).to eq(3)
    end

    it 'applies the same ordering as for admin users' do
      subject
      topic_names = json[:topics].pluck(:name)
      expect(topic_names).to eq(['Apple Topic', 'Mango Topic', 'Zebra Topic'])
    end

    it 'includes all topic information for regular users' do
      subject
      topic = json[:topics].first
      expect(topic).to have_key(:enabled)
      expect(topic).to have_key(:crisis)
      expect(topic).to have_key(:description)
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
