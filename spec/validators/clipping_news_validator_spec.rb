# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClippingNewsValidator do
  describe '#validate' do
    let(:topic) { create(:topic, name: 'Transport') }
    let(:another_topic) { create(:topic, name: 'Health') }
    let(:creator) { create(:user) }
    let(:news_in_topic) do
      create(:news, topic: topic, date: Date.new(2025, 1, 15))
    end
    let(:news_different_topic) do
      create(:news, topic: another_topic, date: Date.new(2025, 1, 16))
    end
    let(:news_outside_range) do
      create(:news, topic: topic, date: Date.new(2025, 2, 1))
    end

    context 'when all news belong to the clipping topic' do
      it 'is valid' do
        clipping = Clipping.new(
          name: 'Test Clipping',
          topic: topic,
          creator: creator,
          start_date: Date.new(2025, 1, 1),
          end_date: Date.new(2025, 1, 31),
          news_ids: [news_in_topic.id]
        )

        expect(clipping).to be_valid
      end
    end

    context 'when some news do not belong to the clipping topic' do
      it 'adds validation error' do
        clipping = Clipping.new(
          name: 'Test Clipping',
          topic: topic,
          creator: creator,
          start_date: Date.new(2025, 1, 1),
          end_date: Date.new(2025, 1, 31),
          news_ids: [news_in_topic.id, news_different_topic.id]
        )

        expect(clipping).not_to be_valid
        expect(clipping.errors[:news_ids]).to include(
          "must all belong to the clipping's topic (Transport)"
        )
      end
    end

    context 'when all news are within date range' do
      it 'is valid' do
        clipping = Clipping.new(
          name: 'Test Clipping',
          topic: topic,
          creator: creator,
          start_date: Date.new(2025, 1, 1),
          end_date: Date.new(2025, 1, 31),
          news_ids: [news_in_topic.id]
        )

        expect(clipping).to be_valid
      end
    end

    context 'when some news are outside date range' do
      it 'adds validation error' do
        clipping = Clipping.new(
          name: 'Test Clipping',
          topic: topic,
          creator: creator,
          start_date: Date.new(2025, 1, 1),
          end_date: Date.new(2025, 1, 31),
          news_ids: [news_in_topic.id, news_outside_range.id]
        )

        expect(clipping).not_to be_valid
        expect(clipping.errors[:news_ids]).to include(
          'must have dates between 2025-01-01 and 2025-01-31'
        )
      end
    end

    context 'when news is on boundary dates' do
      let(:news_on_start) { create(:news, topic: topic, date: Date.new(2025, 1, 1)) }
      let(:news_on_end) { create(:news, topic: topic, date: Date.new(2025, 1, 31)) }

      it 'is valid' do
        clipping = Clipping.new(
          name: 'Test Clipping',
          topic: topic,
          creator: creator,
          start_date: Date.new(2025, 1, 1),
          end_date: Date.new(2025, 1, 31),
          news_ids: [news_on_start.id, news_on_end.id]
        )

        expect(clipping).to be_valid
      end
    end
  end
end
