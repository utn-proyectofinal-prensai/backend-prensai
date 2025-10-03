# frozen_string_literal: true

require 'rails_helper'

describe Clipping do
  let(:creator) { create(:user) }
  let(:base_attributes) do
    {
      name: 'Weekly Summary',
      period_start: Date.current,
      period_end: Date.current + 1.day,
      created_by: creator
    }
  end
  let!(:news) { create(:news) }
  let!(:topic) { create(:topic) }

  describe 'validations' do
    context 'with valid news ids' do
      it 'is valid and normalizes string ids to integers' do
        clipping = described_class.new(base_attributes.merge(news_ids: [news.id.to_s], topic_ids: [topic.id.to_s]))

        expect(clipping).to be_valid
        expect(clipping.news_ids).to eq([news.id])
        expect(clipping.topic_ids).to eq([topic.id])
      end
    end

    context 'with non positive or non numeric ids' do
      it 'adds a validation error' do
        clipping = described_class.new(base_attributes.merge(news_ids: [news.id, -1, 'foo'], topic_ids: [topic.id, 'bar']))

        expect(clipping).not_to be_valid
        expect(clipping.news_ids).to eq([news.id])
        expect(clipping.errors.added?(:news_ids, :invalid, message: 'must contain positive integer IDs')).to be(true)
        expect(clipping.topic_ids).to eq([topic.id])
        expect(clipping.errors.added?(:topic_ids, :invalid, message: 'must contain positive integer IDs')).to be(true)
      end
    end

    context 'with ids of news that do not exist' do
      it 'adds a validation error' do
        missing_id = News.maximum(:id).to_i + 1
        clipping = described_class.new(base_attributes.merge(news_ids: [news.id, missing_id], topic_ids: [topic.id]))

        expect(clipping).not_to be_valid
        expect(clipping.errors.added?(:news_ids, :unknown, message: 'must reference existing news')).to be(true)
      end
    end

    context 'with ids of topics that do not exist' do
      it 'adds a validation error' do
        missing_topic_id = Topic.maximum(:id).to_i + 1
        clipping = described_class.new(base_attributes.merge(news_ids: [news.id], topic_ids: [topic.id, missing_topic_id]))

        expect(clipping).not_to be_valid
        expect(clipping.errors.added?(:topic_ids, :unknown, message: 'must reference existing topics')).to be(true)
      end
    end
  end
end
