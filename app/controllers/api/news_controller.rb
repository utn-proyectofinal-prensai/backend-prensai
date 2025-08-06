class Api::NewsController < ApplicationController
  include JwtAuthenticatable
  
  before_action :authenticate_user!
  
  # GET /api/news
  def index
    limit = params[:limit] || 50
    offset = params[:offset] || 0
    
    where_clause = {}
    where_clause[:tema] = params[:tema] if params[:tema].present?
    where_clause[:medio] = params[:medio] if params[:medio].present?
    where_clause[:valoracion] = params[:valoracion] if params[:valoracion].present?
    
    @news = News.where(where_clause)
                 .order(created_at: :desc)
                 .limit(limit)
                 .offset(offset)
    
    render json: {
      noticias: @news,
      total: @news.count
    }
  end
  
  # GET /api/news/stats
  def stats
    total_noticias = News.count
    
    # Calcular estadísticas por períodos
    noticias_hoy = News.where('DATE(created_at) = ?', Date.current).count
    noticias_esta_semana = News.where('created_at >= ?', 1.week.ago).count
    noticias_este_mes = News.where('created_at >= ?', 1.month.ago).count
    
    ultimas_noticias = News.order(created_at: :desc)
                           .limit(5)
                           .select(:id, :titulo, :medio, :fecha, :created_at)
    
    noticias_por_tema = News.group(:tema)
                            .count
                            .map { |tema, cantidad| { tema: tema, cantidad: cantidad } }
                            .sort_by { |item| -item[:cantidad] }
                            .first(10)
    
    noticias_por_medio = News.group(:medio)
                            .count
                            .map { |medio, cantidad| { medio: medio, cantidad: cantidad } }
                            .sort_by { |item| -item[:cantidad] }
                            .first(10)
    
    render json: {
      totalNoticias: total_noticias,
      noticiasHoy: noticias_hoy,
      noticiasEstaSemana: noticias_esta_semana,
      noticiasEsteMes: noticias_este_mes,
      ultimasNoticias: ultimas_noticias,
      noticiasPorTema: noticias_por_tema,
      noticiasPorMedio: noticias_por_medio
    }
  end
  
  # GET /api/news/:id
  def show
    @news = News.find(params[:id])
    render json: { noticia: @news }
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Noticia no encontrada' }, status: :not_found
  end
  
  # POST /api/news/import
  def import
    if params[:file].blank?
      return render json: { error: 'No se proporcionó archivo' }, status: :bad_request
    end
    
    require 'roo'
    
    begin
      spreadsheet = Roo::Spreadsheet.open(params[:file].path)
      header = spreadsheet.row(1)
      
      # Mapeo de columnas del Excel a campos del modelo
      column_mapping = {
        'TITULO' => :titulo,
        'TIPO PUBLICACION' => :tipo_publicacion,
        'FECHA' => :fecha,
        'SOPORTE' => :soporte,
        'MEDIO' => :medio,
        'SECCION' => :seccion,
        'AUTOR' => :autor,
        'CONDUCTOR' => :conductor,
        'ENTREVISTADO' => :entrevistado,
        'TEMA' => :tema,
        'ETIQUETA1' => :etiqueta1,
        'ETIQUETA2' => :etiqueta2,
        'LINK' => :link,
        'ALCANCE' => :alcance,
        'COTIZACION' => :cotizacion,
        'TAPA' => :tapa,
        'VALORACION' => :valoracion,
        'EJE COMUNICACIONAL' => :eje_comunicacional,
        'FACTOR POLITICO' => :factor_politico,
        'CRISIS' => :crisis,
        'GESTION' => :gestion,
        'AREA' => :area,
        'MENCION1' => :mencion1,
        'MENCION2' => :mencion2,
        'MENCION3' => :mencion3,
        'MENCION4' => :mencion4,
        'MENCION5' => :mencion5
      }
      
      imported_count = 0
      
      (2..spreadsheet.last_row).each do |row_num|
        row_data = Hash[header.zip(spreadsheet.row(row_num))]
        
        news_attributes = {}
        column_mapping.each do |excel_column, model_field|
          news_attributes[model_field] = row_data[excel_column] if row_data[excel_column].present?
        end
        
        News.create!(news_attributes)
        imported_count += 1
      end
      
      render json: {
        message: "Se importaron #{imported_count} noticias correctamente",
        imported_count: imported_count
      }
      
    rescue => e
      render json: { error: "Error al importar: #{e.message}" }, status: :internal_server_error
    end
  end
  
  # POST /api/news/metrics
  def metrics
    news_ids = params[:newsIds]
    
    if news_ids.blank? || !news_ids.is_a?(Array) || news_ids.empty?
      return render json: { error: 'Se requieren IDs de noticias válidos' }, status: :bad_request
    end
    
    selected_news = News.where(id: news_ids)
    
    if selected_news.empty?
      return render json: { error: 'No se encontraron noticias con los IDs proporcionados' }, status: :not_found
    end
    
    soporte_counts = {}
    total_noticias = selected_news.count
    
    selected_news.each do |noticia|
      soporte = noticia.soporte || 'Sin especificar'
      soporte_counts[soporte] = (soporte_counts[soporte] || 0) + 1
    end
    
    soporte_metrics = soporte_counts.map do |soporte, count|
      {
        soporte: soporte,
        cantidad: count,
        porcentaje: ((count.to_f / total_noticias) * 100).round
      }
    end.sort_by { |item| -item[:cantidad] }
    
    metricas = {
      totalNoticias: total_noticias,
      soporte: soporte_metrics,
      resumen: {
        soportesUnicos: soporte_counts.keys.count,
        soporteMasFrecuente: soporte_metrics.first&.dig(:soporte) || 'N/A',
        porcentajeSoporteMasFrecuente: soporte_metrics.first&.dig(:porcentaje) || 0
      }
    }
    
    render json: {
      message: 'Métricas calculadas correctamente',
      metricas: metricas
    }
  end
end