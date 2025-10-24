# frozen_string_literal: true

describe 'GET /api/v1/clippings' do
  subject(:request_index) { get api_v1_clippings_path, headers: auth_headers, as: :json }

  include_context 'with authenticated admin user via JWT'

  let!(:topics) { create_list(:topic, 2) }
  let!(:topic_one_news) { create_list(:news, 2, topic: topics.first, date: Date.current) }
  let!(:topic_two_news) { create(:news, topic: topics.last, date: 5.days.ago.to_date) }
  let!(:clipping_recent) do
    create(
      :clipping,
      name: 'Recent Clipping',
      created_at: 1.day.ago,
      start_date: Date.current,
      end_date: Date.current,
      topic: topics.first,
      news_ids: topic_one_news.map(&:id)
    )
  end
  let!(:clipping_old) do
    create(
      :clipping,
      name: 'Older Clipping',
      created_at: 5.days.ago,
      start_date: 5.days.ago.to_date,
      end_date: 4.days.ago.to_date,
      topic: topics.last,
      news_ids: [topic_two_news.id]
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

  it 'includes topic details and news ids in each clipping', :aggregate_failures do
    request_index
    payload = json[:clippings].first

    expect(payload[:topic]).to include(id: topics.first.id, name: topics.first.name)
    expect(payload[:news_ids]).to match_array(topic_one_news.map(&:id))
    expect(payload[:creator]).to include(:id, :name)
    expect(payload).not_to have_key(:topic_id)
    expect(payload).to have_key(:reviewer)
  end

  it 'returns pagination metadata' do
    request_index
    expect(json[:pagination]).to include(:count, :page, :pages, :next, :prev)
  end

  context 'with pagination params' do
    subject(:request_index) do
      get api_v1_clippings_path(page: 2, limit: 1), headers: auth_headers, as: :json
    end

    it 'respects pagy parameters' do
      request_index
      expect(json[:clippings].size).to eq(1)
      expect(json[:pagination][:page]).to eq 2
    end
  end

  context 'with filtering params' do
    context 'with topic_id filter' do
      subject(:request_index) do
        get api_v1_clippings_path(topic_id: topics.first.id), headers: auth_headers, as: :json
      end

      it 'returns only clippings for the specified topic' do
        request_index
        expect(json[:clippings].size).to eq(1)
        expect(json[:clippings].first[:id]).to eq(clipping_recent.id)
        expect(json[:clippings].first[:topic][:id]).to eq(topics.first.id)
      end
    end

    context 'with news_ids filter' do
      subject(:request_index) do
        get api_v1_clippings_path(news_ids: [topic_one_news.first.id]), headers: auth_headers, as: :json
      end

      it 'returns clippings containing the specified news ids' do
        request_index
        expect(json[:clippings].size).to eq(1)
        expect(json[:clippings].first[:id]).to eq(clipping_recent.id)
      end
    end

    context 'with start_date filter' do
      subject(:request_index) do
        get api_v1_clippings_path(start_date: 3.days.ago.to_date), headers: auth_headers, as: :json
      end

      it 'returns clippings with start_date >= specified date' do
        request_index
        expect(json[:clippings].size).to eq(1)
        expect(json[:clippings].first[:id]).to eq(clipping_recent.id)
      end
    end

    context 'with end_date filter' do
      subject(:request_index) do
        get api_v1_clippings_path(end_date: 2.days.ago.to_date), headers: auth_headers, as: :json
      end

      it 'returns clippings with end_date <= specified date' do
        request_index
        expect(json[:clippings].size).to eq(1)
        expect(json[:clippings].first[:id]).to eq(clipping_old.id)
      end
    end

    context 'with multiple filters combined' do
      subject(:request_index) do
        get api_v1_clippings_path(
          topic_id: topics.first.id,
          news_ids: [topic_one_news.first.id]
        ), headers: auth_headers, as: :json
      end

      it 'applies all filters together' do
        request_index
        expect(json[:clippings].size).to eq(1)
        expect(json[:clippings].first[:id]).to eq(clipping_recent.id)
      end
    end

    context 'with invalid filter params' do
      subject(:request_index) do
        get api_v1_clippings_path(invalid_param: 'value'), headers: auth_headers, as: :json
      end

      it 'ignores invalid params and returns all clippings' do
        request_index
        expect(json[:clippings].size).to eq(2)
      end
    end
  end
end
