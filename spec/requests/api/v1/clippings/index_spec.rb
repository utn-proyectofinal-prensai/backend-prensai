# frozen_string_literal: true

describe 'GET /api/v1/clippings' do
  subject(:request_index) { get api_v1_clippings_path, headers: auth_headers, as: :json }

  include_context 'with authenticated admin user via JWT'

  let!(:topics) { create_list(:topic, 2) }
  let!(:news_items) { create_list(:news, 2) }
  let!(:clipping_recent) do
    create(
      :clipping,
      name: 'Recent Clipping',
      created_at: 1.day.ago,
      topic_ids: topics.map(&:id),
      news_ids: news_items.map(&:id)
    )
  end
  let!(:clipping_old) do
    create(
      :clipping,
      name: 'Older Clipping',
      created_at: 5.days.ago,
      topic_ids: [topics.first.id],
      news_ids: [news_items.first.id]
    )
  end

  it 'returns a successful response' do
    request_index
    expect(response).to have_http_status(:ok)
  end

  it 'orders clippings by creation date descending' do
    request_index
    expect(json[:clippings].pluck(:id)).to eq([clipping_recent.id, clipping_old.id])
  end

  it 'includes topics and news ids in each clipping', :aggregate_failures do
    request_index
    payload = json[:clippings].first

    expect(payload[:topic_ids]).to match_array(topics.map(&:id))
    expect(payload[:news_ids]).to match_array(news_items.map(&:id))
    expect(payload[:created_by]).to include(:id, :name)
  end

  it 'returns pagination metadata' do
    request_index
    expect(json[:pagination]).to include(:count, :page, :pages, :next, :prev)
  end

  context 'with pagination params' do
    subject(:request_index) { get api_v1_clippings_path(page: { number: 2, size: 1 }), headers: auth_headers, as: :json }

    it 'respects pagy parameters' do
      request_index
      expect(json[:clippings].size).to eq(1)
      expect(json[:pagination][:page]).to eq 2
    end
  end
end
