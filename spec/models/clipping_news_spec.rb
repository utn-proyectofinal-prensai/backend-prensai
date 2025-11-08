# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClippingNews do
  describe 'after_commit #refresh_clipping_metrics' do
    it 'destroys the clipping when the last news is removed' do
      clipping = create(:clipping, news_count: 1)

      expect {
        clipping.clipping_news.first.destroy
      }.to change(Clipping, :count).by(-1)
    end

    it 'refreshes metrics when the clipping still has news' do
      clipping = create(:clipping, news_count: 2)
      clipping_news = clipping.clipping_news.first
      original_generated_at = clipping.metrics['generated_at']

      travel 1.minute do
        clipping_news.destroy
      end

      clipping.reload
      expect(clipping.metrics['generated_at']).not_to eq(original_generated_at)
    end
  end
end
