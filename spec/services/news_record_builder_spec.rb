# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NewsRecordBuilder, type: :service do
  subject(:builder) { described_class.new(news_data) }

  let(:topic) { create(:topic, name: 'Transport') }
  let(:mention1) { create(:mention, name: 'Mention1') }
  let(:mention2) { create(:mention, name: 'Mention2') }

  let(:valid_news_data) do
    {
      'TITULO' => 'Test News Title',
      'TIPO PUBLICACION' => 'nota',
      'FECHA' => '2025-01-09',
      'SOPORTE' => 'web',
      'MEDIO' => 'Test Media',
      'SECCION' => 'Politics',
      'AUTOR' => 'Test Author',
      'ENTREVISTADO' => 'Test Interviewee',
      'LINK' => 'https://example.com/news-1',
      'ALCANCE' => 50_000,
      'COTIZACION' => 100.50,
      'VALORACION' => 'positivo',
      'FACTOR POLITICO' => 'alto',
      'TEMA' => 'Transport',
      'MENCIONES' => %w[Mention1 Mention2]
    }
  end

  before do
    # Clean up all news to ensure test idempotency
    News.destroy_all
  end

  before do
    topic
    mention1
    mention2
  end

  describe '.call' do
    it 'creates a news record with correct attributes' do
      expect { described_class.call(valid_news_data) }.to change(News, :count).by(1)

      news = News.last
      expect(news.title).to eq('Test News Title')
      expect(news.publication_type).to eq('nota')
      expect(news.date).to eq(Date.parse('2025-01-09'))
      expect(news.support).to eq('web')
      expect(news.media).to eq('Test Media')
      expect(news.section).to eq('Politics')
      expect(news.author).to eq('Test Author')
      expect(news.interviewee).to eq('Test Interviewee')
      expect(news.link).to eq('https://example.com/news-1')
      expect(news.audience_size).to eq(50_000)
      expect(news.quotation).to eq(100.50)
      expect(news.valuation).to eq('positive')
      expect(news.political_factor).to eq('alto')
      expect(news.topic).to eq(topic)
    end

    it 'associates mentions correctly' do
      described_class.call(valid_news_data)

      news = News.last
      expect(news.mentions.pluck(:name)).to match_array(%w[Mention1 Mention2])
    end

    it 'handles missing mentions gracefully' do
      news_data_without_mentions = valid_news_data.except('MENCIONES')

      expect { described_class.call(news_data_without_mentions) }.to change(News, :count).by(1)

      news = News.last
      expect(news.mentions).to be_empty
    end

    it 'handles nil mentions gracefully' do
      news_data_with_nil_mentions = valid_news_data.merge('MENCIONES' => nil)

      expect { described_class.call(news_data_with_nil_mentions) }.to change(News, :count).by(1)

      news = News.last
      expect(news.mentions).to be_empty
    end

    it 'handles missing topic gracefully' do
      news_data_without_topic = valid_news_data.except('TEMA')

      expect { described_class.call(news_data_without_topic) }.to change(News, :count).by(1)

      news = News.last
      expect(news.topic).to be_nil
    end

    it 'handles blank topic gracefully' do
      news_data_with_blank_topic = valid_news_data.merge('TEMA' => '')

      expect { described_class.call(news_data_with_blank_topic) }.to change(News, :count).by(1)

      news = News.last
      expect(news.topic).to be_nil
    end

    it 'handles missing date gracefully' do
      news_data_without_date = valid_news_data.except('FECHA')

      expect { described_class.call(news_data_without_date) }.to change(News, :count).by(1)

      news = News.last
      expect(news.date).to eq(Date.current)
    end

    it 'handles blank date gracefully' do
      news_data_with_blank_date = valid_news_data.merge('FECHA' => '')

      expect { described_class.call(news_data_with_blank_date) }.to change(News, :count).by(1)

      news = News.last
      expect(news.date).to eq(Date.current)
    end

    it 'handles invalid date gracefully' do
      news_data_with_invalid_date = valid_news_data.merge('FECHA' => 'invalid-date')

      expect { described_class.call(news_data_with_invalid_date) }.to change(News, :count).by(1)

      news = News.last
      expect(news.date).to eq(Date.current)
    end
  end

  describe 'valuation mapping' do
    context 'with positive variations' do
      %w[positiva positivo positive].each do |valuation|
        it "maps '#{valuation}' to 'positive'" do
          news_data = valid_news_data.merge('VALORACION' => valuation)
          described_class.call(news_data)

          news = News.last
          expect(news.valuation).to eq('positive')
        end
      end
    end

    context 'with negative variations' do
      %w[negativa negativo negative].each do |valuation|
        it "maps '#{valuation}' to 'negative'" do
          news_data = valid_news_data.merge('VALORACION' => valuation)
          described_class.call(news_data)

          news = News.last
          expect(news.valuation).to eq('negative')
        end
      end
    end

    context 'with neutral variations' do
      %w[neutra neutro neutral].each do |valuation|
        it "maps '#{valuation}' to 'neutral'" do
          news_data = valid_news_data.merge('VALORACION' => valuation)
          described_class.call(news_data)

          news = News.last
          expect(news.valuation).to eq('neutral')
        end
      end
    end

    context 'with unknown valuation' do
      it 'sets valuation to nil for unknown values' do
        news_data = valid_news_data.merge('VALORACION' => 'unknown_value')
        described_class.call(news_data)

        news = News.last
        expect(news.valuation).to be_nil
      end

      it 'handles nil valuation gracefully' do
        news_data = valid_news_data.merge('VALORACION' => nil)
        described_class.call(news_data)

        news = News.last
        expect(news.valuation).to be_nil
      end
    end
  end

  describe 'edge cases' do
    it 'handles empty string values' do
      news_data_with_empty_values = valid_news_data.transform_values { |_| '' }
      news_data_with_empty_values['TITULO'] = 'Valid Title' # Title cannot be empty
      news_data_with_empty_values['FECHA'] = '2025-01-09' # Date cannot be empty
      news_data_with_empty_values['SOPORTE'] = 'web' # Support cannot be empty
      news_data_with_empty_values['MEDIO'] = 'Test Media' # Media cannot be empty
      news_data_with_empty_values['LINK'] = 'https://example.com/valid' # Link cannot be empty

      expect { described_class.call(news_data_with_empty_values) }.to change(News, :count).by(1)

      news = News.last
      expect(news.title).to eq('Valid Title')
      expect(news.author).to eq('')
      expect(news.interviewee).to eq('')
    end

    it 'handles nil values' do
      news_data_with_nil_values = valid_news_data.transform_values { |_| nil }
      news_data_with_nil_values['TITULO'] = 'Valid Title' # Title cannot be nil
      news_data_with_nil_values['FECHA'] = '2025-01-09' # Date cannot be nil
      news_data_with_nil_values['SOPORTE'] = 'web' # Support cannot be nil
      news_data_with_nil_values['MEDIO'] = 'Test Media' # Media cannot be nil
      news_data_with_nil_values['LINK'] = 'https://example.com/valid' # Link cannot be nil

      expect { described_class.call(news_data_with_nil_values) }.to change(News, :count).by(1)

      news = News.last
      expect(news.title).to eq('Valid Title')
      expect(news.author).to be_nil
      expect(news.interviewee).to be_nil
    end
  end
end
