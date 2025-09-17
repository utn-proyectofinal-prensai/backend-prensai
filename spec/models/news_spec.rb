# frozen_string_literal: true

describe News do
  describe 'associations' do
    it { is_expected.to belong_to(:topic).optional }
    it { is_expected.to have_many(:mention_news).dependent(:destroy) }
    it { is_expected.to have_many(:mentions).through(:mention_news) }
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
end
