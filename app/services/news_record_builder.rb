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
      title: news_data['TITULO'],
      publication_type: news_data['TIPO PUBLICACION'], # puede venir "REVISAR MANUAL"
      date: parse_date(news_data['FECHA']),
      support: news_data['SOPORTE'],
      media: news_data['MEDIO'],
      section: news_data['SECCION'],
      author: news_data['AUTOR'],
      interviewee: news_data['ENTREVISTADO'],
      link: news_data['LINK'],
      audience_size: news_data['ALCANCE'],
      quotation: news_data['COTIZACION'],
      valuation: map_valuation(news_data['VALORACION']), # puede venir "REVISAR MANUAL"
      political_factor: news_data['FACTOR POLITICO'], # puede venir "REVISAR MANUAL"
      topic: find_topic(news_data['TEMA'])
    }
  end
  # rubocop:enable Metrics/AbcSize

  def associate_mentions(news_record)
    return unless news_data['MENCIONES'].is_a?(Array)

    news_data['MENCIONES'].each do |mention_name|
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
    when 'positiva', 'positivo', 'positive'
      'positive'
    when 'negativa', 'negativo', 'negative'
      'negative'
    when 'neutra', 'neutro', 'neutral'
      'neutral'
    end
  end
end
