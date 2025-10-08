# frozen_string_literal: true

require 'rails_helper'

describe News do
  include ActiveSupport::Testing::TimeHelpers

  describe 'associations' do
    it { is_expected.to belong_to(:topic).optional }
    it { is_expected.to have_many(:mention_news).dependent(:destroy) }
    it { is_expected.to have_many(:mentions).through(:mention_news) }
    it { is_expected.to have_many(:clipping_news).dependent(:destroy) }
    it { is_expected.to have_many(:clippings).through(:clipping_news) }
  end

  describe 'validations' do
    subject { build(:news) }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_presence_of(:support) }
    it { is_expected.to validate_presence_of(:media) }
  end

  describe 'enums' do
    it {
      expect(subject).to define_enum_for(:valuation)
        .with_values(positive: 'positive', neutral: 'neutral', negative: 'negative')
        .with_prefix(true)
        .backed_by_column_of_type(:string)
    }
  end

  describe 'scopes' do
    describe '.ordered' do
      let!(:old_news) { create(:news, date: 1.week.ago) }
      let!(:new_news) { create(:news, date: 1.day.ago) }

      it 'orders news by date descending' do
        expect(described_class.ordered).to eq([new_news, old_news])
      end
    end
  end

  describe 'callbacks' do
    context 'when metric attributes change' do
      let(:topic) { create(:topic) }
      let!(:news) do
        create(
          :news,
          topic: topic,
          valuation: 'neutral',
          media: 'Clarín',
          support: 'Print',
          date: Date.new(2025, 1, 2),
          audience_size: 1_000,
          quotation: 150.5
        )
      end
      let!(:clipping) { create(:clipping, topic: topic, news_ids: [news.id]) }

      it 'refreshes metrics for related clippings' do
        initial_generated_at = clipping.metrics['generated_at']

        travel_to Time.zone.local(2025, 1, 3, 9, 15) do
          news.update!(valuation: 'positive', media: 'La Nación')
        end

        clipping.reload
        expect(clipping.metrics['generated_at']).not_to eq(initial_generated_at)
        expect(clipping.metrics['generated_at']).to eq(Time.zone.local(2025, 1, 3, 9, 15).iso8601)
        expect(clipping.metrics['valuation']['positive']['count']).to eq(1)
        expect(clipping.metrics['media_stats']['items']).to contain_exactly(
          { 'key' => 'La Nación', 'count' => 1, 'percentage' => 100.0 }
        )
      end
    end

    context 'when news is created' do
      let(:topic) { create(:topic) }
      let(:news) { build(:news, topic: topic) }

      it 'calls check_topic_crisis after create' do
        allow(topic).to receive(:check_crisis!)
        news.save!
        expect(topic).to have_received(:check_crisis!)
      end
    end

    context 'when valuation is updated' do
      let(:topic) { create(:topic) }
      let(:news) { create(:news, topic: topic, valuation: 'neutral') }

      it 'calls check_topic_crisis after valuation change' do
        allow(topic).to receive(:check_crisis!)
        news.update!(valuation: 'negative')
        expect(topic).to have_received(:check_crisis!).at_least(:once)
      end
    end

    context 'when topic_id is updated' do
      let(:old_topic) { create(:topic) }
      let(:new_topic) { create(:topic) }
      let(:news) { create(:news, topic: old_topic) }

      it 'calls check_crisis on both old and new topic' do
        allow(old_topic).to receive(:check_crisis!)
        allow(new_topic).to receive(:check_crisis!)
        news.update!(topic: new_topic)
        expect(old_topic).to have_received(:check_crisis!)
        expect(new_topic).to have_received(:check_crisis!)
      end
    end

    context 'when news is destroyed' do
      let(:topic) { create(:topic) }
      let(:news) { create(:news, topic: topic) }

      it 'calls check_topic_crisis after destroy' do
        allow(topic).to receive(:check_crisis!)
        news.destroy!
        expect(topic).to have_received(:check_crisis!).at_least(:once)
      end
    end
  end

  describe '#check_topic_crisis' do
    let(:topic) { create(:topic) }
    let(:news) { create(:news, topic: topic) }

    context 'when topic has changed' do
      let(:new_topic) { create(:topic) }

      it 'checks crisis on old topic when topic changes' do
        original_topic_id = news.topic_id
        allow(Topic).to receive(:find).with(original_topic_id).and_return(topic)
        allow(topic).to receive(:check_crisis!)
        allow(new_topic).to receive(:check_crisis!)

        news.update!(topic: new_topic)
        expect(topic).to have_received(:check_crisis!)
        expect(new_topic).to have_received(:check_crisis!)
      end
    end
  end

  describe '#requires_manual_review?' do
    let(:topic) { create(:topic) }
    let(:valid_attributes) do
      {
        publication_type: 'Nota',
        political_factor: 'SI',
        interviewee: 'Juan Pérez',
        valuation: 'positive',
        topic: topic
      }
    end

    it 'returns false when all fields are valid' do
      expect(build(:news, valid_attributes).requires_manual_review?).to be false
    end

    it 'returns true when a manual review string field is set' do
      field = %i[publication_type political_factor interviewee].sample
      expect(build(:news, valid_attributes.merge(field => 'REVISAR MANUAL')).requires_manual_review?).to be true
    end

    it 'returns true when a required field is nil' do
      field = %i[valuation topic].sample
      expect(build(:news, valid_attributes.merge(field => nil)).requires_manual_review?).to be true
    end
  end

  describe '#prevent_topic_change_when_clipped' do
    it 'blocks topic changes when the news belongs to a clipping of the current topic' do
      original_topic = create(:topic)
      another_topic = create(:topic)
      news = create(:news, topic: original_topic)
      create(:clipping, topic: original_topic, news_ids: [news.id])

      result = news.update(topic: another_topic)

      expect(result).to be_falsey
      message = I18n.t('activerecord.errors.models.news.attributes.topic_id.clipping_restriction')
      expect(news.errors[:topic_id]).to include(message)
      expect(news.reload.topic).to eq(original_topic)
    end

    it 'allows topic changes when there are no clippings for the current topic' do
      original_topic = create(:topic)
      another_topic = create(:topic)
      news = create(:news, topic: original_topic)

      expect(news.update(topic: another_topic)).to be_truthy
      expect(news.reload.topic).to eq(another_topic)
    end
  end

  describe '#ensure_date_within_clipping_bounds' do
    it 'blocks moving the date outside linked clippings range' do
      topic = create(:topic)
      news = create(:news, topic: topic, date: Date.new(2025, 1, 10))
      create(:clipping, topic: topic, start_date: Date.new(2025, 1, 1), end_date: Date.new(2025, 1, 15),
                        news_ids: [news.id])

      result = news.update(date: Date.new(2025, 2, 1))

      expect(result).to be_falsey
      message = I18n.t('activerecord.errors.models.news.attributes.date.clipping_bounds')
      expect(news.errors[:date]).to include(message)
      expect(news.reload.date).to eq(Date.new(2025, 1, 10))
    end

    it 'allows changing the date within all linked clipping ranges' do
      topic = create(:topic)
      news = create(:news, topic: topic, date: Date.new(2025, 1, 10))
      create(:clipping, topic: topic, start_date: Date.new(2025, 1, 1), end_date: Date.new(2025, 1, 15),
                        news_ids: [news.id])

      expect(news.update(date: Date.new(2025, 1, 12))).to be_truthy
      expect(news.reload.date).to eq(Date.new(2025, 1, 12))
    end
  end
end
