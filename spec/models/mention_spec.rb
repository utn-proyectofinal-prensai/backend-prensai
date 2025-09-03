# frozen_string_literal: true

describe Mention do
  describe 'associations' do
    it { is_expected.to have_many(:mention_news).dependent(:restrict_with_exception) }
    it { is_expected.to have_many(:news).through(:mention_news) }
  end

  describe 'validations' do
    subject { build(:mention) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end

  describe 'scopes' do
    describe '.ordered' do
      let!(:mention_z) { create(:mention, name: 'Zebra') }
      let!(:mention_a) { create(:mention, name: 'Apple') }
      let!(:mention_m) { create(:mention, name: 'Mango') }

      it 'orders mentions by name alphabetically' do
        expect(described_class.ordered).to eq([mention_a, mention_m, mention_z])
      end
    end
  end

  describe 'database constraints' do
    context 'when creating mentions with duplicate names' do
      before { create(:mention, name: 'Test Mention') }

      it 'raises validation error for duplicate name' do
        duplicate_mention = build(:mention, name: 'Test Mention')
        expect(duplicate_mention).not_to be_valid
        expect(duplicate_mention.errors[:name]).to include(I18n.t('errors.messages.taken'))
      end
    end
  end

  describe 'associations behavior' do
    let(:mention) { create(:mention) }
    let!(:news_item) { create(:news) }

    context 'when adding news to mention' do
      it 'creates mention_news join record' do
        expect { mention.news << news_item }.to change(MentionNews, :count).by(1)
      end

      it 'allows accessing associated news' do
        mention.news << news_item
        expect(mention.news).to include(news_item)
        expect(news_item.reload.mentions).to include(mention)
      end
    end

    context 'when destroying mention with associated news' do
      before { mention.news << news_item }

      it 'destroys mention_news join records but keeps news' do
        expect { mention.destroy! }.to change(MentionNews, :count).by(-1)
        expect(News.exists?(news_item.id)).to be true
      end
    end
  end
end
