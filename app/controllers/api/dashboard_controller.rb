class Api::DashboardController < ApplicationController
  include JwtAuthenticatable
  
  before_action :authenticate_user!
  
  # GET /api/dashboard/stats
  def stats
    total_noticias = News.count
    noticias_hoy = News.where('DATE(created_at) = ?', Date.current).count
    noticias_esta_semana = News.where('created_at >= ?', 1.week.ago).count
    noticias_este_mes = News.where('created_at >= ?', 1.month.ago).count
    
    # Contar eventos activos
    eventos_activos = Event.where(active: true).count
    
    # Contar menciones activas
    menciones_activas = ActiveMention.where(active: true).count
    
    # Estadísticas por tema (top 10)
    noticias_por_tema = News.group(:tema)
                            .count
                            .map { |tema, cantidad| { tema: tema, cantidad: cantidad } }
                            .sort_by { |item| -item[:cantidad] }
                            .first(10)
    
    # Estadísticas por medio (top 10)
    noticias_por_medio = News.group(:medio)
                            .count
                            .map { |medio, cantidad| { medio: medio, cantidad: cantidad } }
                            .sort_by { |item| -item[:cantidad] }
                            .first(10)
    
    # Estadísticas por valoración
    valoraciones = News.group(:valoracion).count
    
    render json: {
      totalNoticias: total_noticias,
      noticiasHoy: noticias_hoy,
      noticiasEstaSemana: noticias_esta_semana,
      noticiasEsteMes: noticias_este_mes,
      eventosActivos: eventos_activos,
      mencionesActivas: menciones_activas,
      noticiasPorTema: noticias_por_tema,
      noticiasPorMedio: noticias_por_medio,
      valoraciones: valoraciones
    }
  end
  
  # GET /api/dashboard/latest-news
  def latest_news
    limit = params[:limit] || 5
    @latest_news = News.order(created_at: :desc).limit(limit)
    
    render json: {
      latest_news: @latest_news,
      total: @latest_news.count
    }
  end
  
  # GET /api/dashboard/active-events
  def active_events
    @active_events = Event.where(active: true).order(created_at: :desc)
    
    render json: {
      active_events: @active_events,
      total: @active_events.count
    }
  end
  
  # GET /api/dashboard/active-mentions
  def active_mentions
    @active_mentions = ActiveMention.where(active: true).order(created_at: :desc)
    
    render json: {
      active_mentions: @active_mentions,
      total: @active_mentions.count
    }
  end
end 