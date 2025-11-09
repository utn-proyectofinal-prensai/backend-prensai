# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClippingNewsValidator do
  describe '#validate' do
    subject(:clipping) do
      Clipping.new(
        name: 'Test Clipping',
        topic: topic,
        creator: creator,
        start_date: start_date,
        end_date: end_date,
        news_ids: news_ids
      )
    end

    let(:topic) { create(:topic, name: 'Transport') }
    let(:another_topic) { create(:topic, name: 'Health') }
    let(:creator) { create(:user) }
    let(:start_date) { Date.new(2025, 1, 1) }
    let(:end_date) { Date.new(2025, 1, 31) }
    let(:news_in_topic) { create(:news, topic: topic, date: Date.new(2025, 1, 15)) }
    let(:news_ids) { [news_in_topic.id] }

    describe 'topic validation' do
      context 'when all news belong to the clipping topic' do
        it { is_expected.to be_valid }
      end

      context 'when some news do not belong to the clipping topic' do
        let(:news_different_topic) { create(:news, topic: another_topic, date: Date.new(2025, 1, 16)) }
        let(:news_ids) { [news_in_topic.id, news_different_topic.id] }

        it 'adds validation error' do
          expect(clipping).not_to be_valid
          expect(clipping.errors[:news_ids]).to include(
            I18n.t('activerecord.errors.models.clipping.attributes.news_ids.topic_mismatch',
                   topic_name: topic.name)
          )
        end
      end
    end

    describe 'date range validation' do
      context 'when all news are within date range' do
        it { is_expected.to be_valid }
      end

      context 'when some news are outside date range' do
        let(:news_outside_range) { create(:news, topic: topic, date: Date.new(2025, 2, 1)) }
        let(:news_ids) { [news_in_topic.id, news_outside_range.id] }

        it 'adds validation error' do
          expect(clipping).not_to be_valid
          expect(clipping.errors[:news_ids]).to include(
            I18n.t('activerecord.errors.models.clipping.attributes.news_ids.date_out_of_range',
                   start_date: start_date, end_date: end_date)
          )
        end
      end

      context 'when news is on boundary dates' do
        let(:news_on_start) { create(:news, topic: topic, date: start_date) }
        let(:news_on_end) { create(:news, topic: topic, date: end_date) }
        let(:news_ids) { [news_on_start.id, news_on_end.id] }

        it { is_expected.to be_valid }
      end
    end
  end
end
