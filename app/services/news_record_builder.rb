# frozen_string_literal: true

class NewsRecordBuilder
  include ActiveModel::Model

  attr_accessor :news_data, :creator_id

  def self.call(news_data, creator_id = nil)
    new(news_data, creator_id).build
  end

  def initialize(news_data, creator_id = nil)
    @news_data = news_data
    @creator_id = creator_id
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
      plain_text: news_data['TEXTO_PLANO'],
      audience_size: parse_audience_size(news_data['ALCANCE']),
      quotation: parse_quotation(news_data['COTIZACION']),
      valuation: map_valuation(news_data['VALORACION']), # puede venir "REVISAR MANUAL"
      political_factor: news_data['FACTOR POLITICO'], # puede venir "REVISAR MANUAL"
      topic: find_topic(news_data['TEMA']),
      creator_id: creator_id
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

  # "3.500" -> 3500, "3,500" -> 3500, 3500 -> 3500
  def parse_audience_size(value)
    return if value.nil? || (value.is_a?(String) && value.strip.empty?)
    return value if value.is_a?(Integer)

    digits = value.to_s.gsub(/[^\d]/, '')
    return if digits.empty?

    digits.to_i
  end

  # Normaliza formatos de moneda comunes en ES/AR/LA:
  # - "$75.000" -> 75000.00
  # - "1.234,56" -> 1234.56
  # - "100,50" -> 100.50
  # - "100.50" -> 100.50
  def parse_quotation(value)
    return if value.nil? || (value.is_a?(String) && value.strip.empty?)
    return value if value.is_a?(Numeric)

    str = value.to_s.strip
    # Quita símbolos de moneda y espacios pero conserva separadores y signo
    str = str.gsub(/[^\d\.,-]/, '')

    if str.include?('.') && str.include?(',')
      # Supone formato "1.234,56": punto miles, coma decimales
      str = str.delete('.')
      str = str.sub(',', '.')
    elsif str.include?(',')
      # Solo coma: tratar como separador decimal
      str = str.tr(',', '.')
    elsif str.include?('.')
      # Solo punto: decidir si es miles o decimal
      parts = str.split('.')
      if parts.length > 1 && parts.last.length == 3 && parts[0..-2].all? { |p| p.length.between?(1, 3) }
        # Parece separador de miles
        str = parts.join('')
      end
    end

    return if str.empty? || str == '-' || str == '.'

    BigDecimal(str)
  rescue ArgumentError
    nil
  end
end
