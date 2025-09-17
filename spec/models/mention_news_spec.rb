# frozen_string_literal: true

describe MentionNews do
  describe 'associations' do
    it { is_expected.to belong_to(:mention) }
    it { is_expected.to belong_to(:news) }
  end

  describe 'validations' do
    subject { build(:mention_news, mention: mention, news: news) }

    let(:mention) { create(:mention) }
    let(:news) { create(:news) }

    it { is_expected.to validate_uniqueness_of(:mention_id).scoped_to(:news_id) }
  end

  describe 'database constraints' do
    let(:mention) { create(:mention) }
    let(:news) { create(:news) }

    context 'when creating duplicate mention-news combination' do
      before { create(:mention_news, mention: mention, news: news) }

      it 'prevents duplicate associations' do
        duplicate_association = build(:mention_news, mention: mention, news: news)
        expect(duplicate_association).not_to be_valid
        expect(duplicate_association.errors[:mention_id]).to include(I18n.t('errors.messages.taken'))
      end
    end

    context 'when creating valid associations' do
      it 'allows same mention with different news' do
        news2 = create(:news)

        association1 = create(:mention_news, mention: mention, news: news)
        association2 = build(:mention_news, mention: mention, news: news2)

        expect(association1).to be_valid
        expect(association2).to be_valid
      end

      it 'allows same news with different mentions' do
        mention2 = create(:mention)

        association1 = create(:mention_news, mention: mention, news: news)
        association2 = build(:mention_news, mention: mention2, news: news)

        expect(association1).to be_valid
        expect(association2).to be_valid
      end
    end
  end

  describe 'join table functionality' do
    let(:mention) { create(:mention) }
    let(:news_item) { create(:news) }

    it 'properly connects mentions and news' do
      mention_news = create(:mention_news, mention: mention, news: news_item)

      expect(mention_news.mention).to eq(mention)
      expect(mention_news.news).to eq(news_item)
      expect(mention.news).to include(news_item)
      expect(news_item.reload.mentions).to include(mention)
    end

    context 'when mention is destroyed' do
      before { create(:mention_news, mention: mention, news: news_item) }

      it 'prevents deletion due to restrict_with_exception' do
        expect { mention.destroy! }.to raise_error(ActiveRecord::DeleteRestrictionError)
        expect(Mention.exists?(mention.id)).to be true
        expect(News.exists?(news_item.id)).to be true
      end
    end

    context 'when news is destroyed' do
      before { create(:mention_news, mention: mention, news: news_item) }

      it 'destroys the join record' do
        expect { news_item.destroy! }.to change(described_class, :count).by(-1)
      end

      it 'keeps the mention record' do
        news_item.destroy!
        expect(Mention.exists?(mention.id)).to be true
      end
    end
  end
end
