# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClippingConstraintsValidator do
  describe '#validate' do
    let(:topic) { create(:topic) }
    let(:another_topic) { create(:topic) }
    let(:news) { create(:news, topic: topic, date: Date.new(2025, 1, 15)) }

    context 'when news is not in any clipping' do
      it 'allows topic change' do
        news.topic = another_topic
        expect(news).to be_valid
      end

      it 'allows date change' do
        news.date = Date.new(2025, 2, 1)
        expect(news).to be_valid
      end
    end

    context 'when news belongs to a clipping' do
      let(:clipping) do
        create(:clipping,
               topic: topic,
               start_date: Date.new(2025, 1, 1),
               end_date: Date.new(2025, 1, 31),
               news_ids: [news.id])
      end

      before { clipping }

      context 'with topic validation' do
        it 'prevents changing topic when clipping uses the current topic' do
          news.topic = another_topic
          expect(news).not_to be_valid
          expect(news.errors[:topic_id]).to include(
            'cannot be changed while the news belongs to clippings for the current topic'
          )
        end

        it 'allows changing topic when clipping is updated to different topic first' do
          clipping.update!(topic: another_topic)

          new_topic = create(:topic)
          news.topic = new_topic

          expect(news).to be_valid
        end
      end

      context 'with date validation' do
        it 'prevents moving date outside clipping range (before start)' do
          news.date = Date.new(2024, 12, 31)
          expect(news).not_to be_valid
          expect(news.errors[:date]).to include(
            'cannot move outside the date range of linked clippings'
          )
        end

        it 'prevents moving date outside clipping range (after end)' do
          news.date = Date.new(2025, 2, 1)
          expect(news).not_to be_valid
          expect(news.errors[:date]).to include(
            'cannot move outside the date range of linked clippings'
          )
        end

        it 'allows moving date within clipping range' do
          news.date = Date.new(2025, 1, 20)
          expect(news).to be_valid
        end

        it 'allows moving date on clipping boundaries' do
          news.date = Date.new(2025, 1, 1)
          expect(news).to be_valid

          news.date = Date.new(2025, 1, 31)
          expect(news).to be_valid
        end
      end
    end

    context 'when creating a new news record' do
      it 'does not run clipping validations' do
        new_news = build(:news, topic: topic, date: Date.new(2025, 1, 1))
        expect(new_news).to be_valid
      end
    end
  end
end
