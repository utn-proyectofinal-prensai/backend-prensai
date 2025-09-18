# frozen_string_literal: true

RSpec.describe NewsReviewCreator, type: :service do
  subject(:service_call) { described_class.call(news:, reviewer:, attributes:, notes:) }

  let(:news) { create(:news, valuation: 'neutral', political_factor: 'regional') }
  let(:reviewer) { create(:user) }
  let(:notes) { 'Revisión de valoración' }

  context 'when changing scalar attributes' do
    let(:attributes) { { valuation: 'positive', political_factor: 'nacional' } }

    it 'updates the news record and stores the review' do
      result = nil
      expect { result = service_call }.to change(NewsReview, :count).by(1)
      expect(result).to be_success

      news.reload
      expect(news.valuation).to eq('positive')
      expect(news.political_factor).to eq('nacional')

      review = result.payload
      expect(review.changeset['valuation']['before']).to eq('neutral')
      expect(review.changeset['valuation']['after']).to eq('positive')
      expect(review.notes).to eq(notes)
      expect(news.latest_review.reviewer).to eq(reviewer)
    end
  end

  context 'when updating mentions' do
    let(:attributes) { { mention_ids: [new_mention.id] } }
    let(:new_mention) { create(:mention) }

    before do
      news.mentions << create(:mention)
    end

    it 'replaces the associations and records the difference' do
      result = service_call

      expect(result).to be_success
      review = result.payload

      expect(review.changeset['mention_ids']['after']).to match_array([new_mention.id])
      expect(review.changeset['mention_ids']['before']).not_to be_empty
    end
  end

  context 'when no changes are provided' do
    let(:attributes) { {} }
    let(:notes) { nil }

    it 'returns a failure result' do
      result = service_call

      expect(result).to be_failure
      expect(result.errors.first).to include('Debe enviar al menos un cambio')
    end
  end

  context 'when mention identifiers are invalid' do
    let(:attributes) { { mention_ids: [999_999] } }

    it 'returns a failure result without persisting records' do
      expect { service_call }.not_to change(NewsReview, :count)

      result = service_call
      expect(result).to be_failure
      expect(result.errors.first).to include('no son válidas')
    end
  end
end
