# frozen_string_literal: true

class NewsRecordBuilder
  include ActiveModel::Model

  attr_accessor :news_data

  def self.call(news_data)
    new(news_data).build
  end

  def initialize(news_data)
    @news_data = news_data
  end

  def build
    news_record = News.create(news_attributes)
    associate_mentions(news_record) if news_record.persisted?
    news_record
  end

  private

  # rubocop:disable Metrics/AbcSize
  def news_attributes
    {
      title: news_data['titulo'],
      publication_type: news_data['tipo_publicacion'],
      date: parse_date(news_data['fecha']),
      support: news_data['soporte'],
      media: news_data['medio'],
      section: news_data['seccion'],
      author: news_data['autor'],
      interviewee: news_data['entrevistado'],
      link: news_data['link'],
      audience_size: news_data['alcance'],
      quotation: news_data['cotizacion'],
      valuation: map_valuation(news_data['valoracion']),
      political_factor: news_data['factor_politico'],
      management: news_data['gestion'],
      plain_text: news_data['texto_plano'],
      topic: find_topic(news_data['tema'])
    }
  end
  # rubocop:enable Metrics/AbcSize

  def associate_mentions(news_record)
    return unless news_data['menciones'].is_a?(Array)

    news_data['menciones'].each do |mention_name|
      mention = Mention.find_by(name: mention_name)
      news_record.mentions << mention if mention
    end
  end

  def find_topic(topic_name)
    return if topic_name.blank?

    Topic.find_by(name: topic_name)
  end

  def parse_date(date_str)
    return Date.current if date_str.blank?

    Date.parse(date_str)
  rescue Date::Error
    Date.current
  end

  def map_valuation(valuation)
    case valuation&.downcase
    when 'positivo', 'positive'
      'positive'
    when 'negativo', 'negative'
      'negative'
    else
      'neutral'
    end
  end
end
