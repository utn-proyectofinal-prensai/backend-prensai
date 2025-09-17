# frozen_string_literal: true

module NumberParser
  extend self

  # Parsea valores monetarios con diferentes formatos de separadores
  # Ejemplos:
  # - "$75.000" -> 75000.00
  # - "1.234,56" -> 1234.56
  # - "100,50" -> 100.50
  # - "100.50" -> 100.50
  def parse_currency(value)
    return if invalid_value?(value)
    return value if value.is_a?(Numeric)

    str = clean_currency_string(value)
    normalized_str = normalize_separators(str)

    return if invalid_normalized_string?(normalized_str)

    BigDecimal(normalized_str)
  rescue ArgumentError
    nil
  end

  # Parsea tamaños de audiencia eliminando separadores de miles
  # Ejemplos: "3.500" -> 3500, "3,500" -> 3500, 3500 -> 3500
  def parse_audience_size(value)
    return if invalid_value?(value)
    return value if value.is_a?(Integer)

    digits = value.to_s.gsub(/[^\d]/, '')
    return if digits.empty?

    digits.to_i
  end

  private

  def invalid_value?(value)
    value.nil? || (value.is_a?(String) && value.strip.empty?)
  end

  def clean_currency_string(value)
    str = value.to_s.strip
    # Quita símbolos de moneda y espacios pero conserva separadores y signo
    str.gsub(/[^\d\.,-]/, '')
  end

  def normalize_separators(str)
    if str.include?('.') && str.include?(',')
      normalize_european_format(str)
    elsif str.include?(',')
      normalize_comma_separator(str)
    elsif str.include?('.')
      normalize_dot_separator(str)
    else
      str
    end
  end

  def normalize_european_format(str)
    # Formato "1.234,56": punto miles, coma decimales
    str.delete('.').sub(',', '.')
  end

  def normalize_comma_separator(str)
    # Solo coma: tratar como separador decimal
    str.tr(',', '.')
  end

  def normalize_dot_separator(str)
    # Solo punto: decidir si es miles o decimal
    parts = str.split('.')
    if thousand_separator?(parts)
      parts.join
    else
      str
    end
  end

  def thousand_separator?(parts)
    parts.length > 1 &&
      parts.last.length == 3 &&
      parts[0..-2].all? { |p| p.length.between?(1, 3) }
  end

  def invalid_normalized_string?(str)
    str.empty? || str == '-' || str == '.'
  end
end
