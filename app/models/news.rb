class News < ApplicationRecord
  validates :titulo, presence: true
  validates :fecha, presence: true
  validates :soporte, presence: true
  validates :medio, presence: true
  
  # Scopes para filtros
  scope :by_tema, ->(tema) { where(tema: tema) if tema.present? }
  scope :by_medio, ->(medio) { where(medio: medio) if medio.present? }
  scope :by_valoracion, ->(valoracion) { where(valoracion: valoracion) if valoracion.present? }
  scope :recent, -> { order(created_at: :desc) }
  
  # Metodos para estadisticas
  def self.stats_by_soporte
    group(:soporte).count
  end
  
  def self.stats_by_medio
    group(:medio).count
  end
  
  def self.stats_by_tema
    group(:tema).count
  end
end
