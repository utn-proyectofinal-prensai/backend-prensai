# frozen_string_literal: true

# rubocop:disable Rails/SkipsModelValidations

describe Topic do
  describe 'associations' do
    it { is_expected.to have_many(:news).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    subject { build(:topic) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end

  describe 'scopes' do
    describe '.ordered' do
      let!(:topic_z) { create(:topic, name: 'Zebra Topic') }
      let!(:topic_a) { create(:topic, name: 'Apple Topic') }
      let!(:topic_m) { create(:topic, name: 'Mango Topic') }

      it 'orders topics by name alphabetically' do
        expect(described_class.ordered).to eq([topic_a, topic_m, topic_z])
      end
    end
  end

  describe 'defaults' do
    it 'sets default enabled to true' do
      topic = described_class.new
      expect(topic.enabled).to be true
    end

    it 'sets default crisis to false' do
      topic = described_class.new
      expect(topic.crisis).to be false
    end
  end

  describe '#check_crisis!' do
    let(:topic) { create(:topic) }

    context 'when topic has more than 5 negative news' do
      it 'sets crisis to true' do
        # Create 6 negative news using insert_all to avoid callbacks
        news_attributes = Array.new(5) do
          {
            title: 'Test News',
            publication_type: 'article',
            date: Date.current,
            support: 'negative',
            media: 'Test Media',
            valuation: 'negative',
            link: "https://example.com/news-#{SecureRandom.uuid}",
            topic_id: topic.id,
            created_at: Time.current,
            updated_at: Time.current
          }
        end
        News.insert_all(news_attributes)

        expect { topic.check_crisis! }.to change(topic, :crisis).from(false).to(true)
      end
    end

    context 'when topic has 4 or fewer negative news' do
      it 'keeps crisis as false' do
        # Create 5 negative news using insert_all
        news_attributes = Array.new(4) do
          {
            title: 'Test News',
            publication_type: 'article',
            date: Date.current,
            support: 'negative',
            media: 'Test Media',
            valuation: 'negative',
            link: "https://example.com/news-#{SecureRandom.uuid}",
            topic_id: topic.id,
            created_at: Time.current,
            updated_at: Time.current
          }
        end
        News.insert_all(news_attributes)

        expect { topic.check_crisis! }.not_to change(topic, :crisis)
        expect(topic.crisis).to be false
      end
    end

    context 'when topic was in crisis and negative news decrease' do
      it 'sets crisis to false' do
        # Set topic as in crisis initially
        topic.update_column(:crisis, true)

        # Create only 3 negative news (below threshold) using insert_all
        news_attributes = Array.new(3) do
          {
            title: 'Test News',
            publication_type: 'article',
            date: Date.current,
            support: 'negative',
            media: 'Test Media',
            valuation: 'negative',
            link: "https://example.com/news-#{SecureRandom.uuid}",
            topic_id: topic.id,
            created_at: Time.current,
            updated_at: Time.current
          }
        end
        News.insert_all(news_attributes)

        expect { topic.check_crisis! }.to change(topic, :crisis).from(true).to(false)
      end
    end
  end

  describe 'restrict_with_error dependency' do
    let(:topic) { create(:topic) }

    context 'when topic has associated news' do
      before { create(:news, topic: topic) }

      it 'prevents deletion and raises error' do
        expect { topic.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
        expect(described_class.exists?(topic.id)).to be true
      end
    end

    context 'when topic has no associated news' do
      it 'allows deletion' do
        expect { topic.destroy! }.not_to raise_error
        expect(described_class.exists?(topic.id)).to be false
      end
    end
  end

  describe 'database constraints' do
    context 'when creating topics with duplicate names' do
      before { create(:topic, name: 'Test Topic') }

      it 'raises validation error for duplicate name' do
        duplicate_topic = build(:topic, name: 'Test Topic')
        expect(duplicate_topic).not_to be_valid
        expect(duplicate_topic.errors[:name]).to include(I18n.t('errors.messages.taken'))
      end
    end
  end
end

# rubocop:enable Rails/SkipsModelValidations
