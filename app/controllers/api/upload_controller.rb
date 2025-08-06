class Api::UploadController < ApplicationController
  include JwtAuthenticatable
  
  before_action :authenticate_user!
  
  # POST /api/upload/preview
  def preview
    if params[:file].blank?
      return render json: { error: 'No se proporcionó archivo' }, status: :bad_request
    end
    
    file = params[:file]
    
    # Validar tipo de archivo
    unless ['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 
            'application/vnd.ms-excel',
            'text/csv'].include?(file.content_type)
      return render json: { error: 'Tipo de archivo no soportado. Use Excel (.xlsx, .xls) o CSV' }, status: :bad_request
    end
    
    require 'roo'
    
    begin
      spreadsheet = Roo::Spreadsheet.open(file.path)
      header = spreadsheet.row(1)
      
      # Obtener las primeras 5 filas para previsualización
      preview_rows = []
      (2..[6, spreadsheet.last_row].min).each do |row_num|
        preview_rows << Hash[header.zip(spreadsheet.row(row_num))]
      end
      
      render json: {
        message: 'Archivo previsualizado correctamente',
        headers: header,
        preview_rows: preview_rows,
        total_rows: spreadsheet.last_row - 1
      }
      
    rescue => e
      render json: { error: "Error al previsualizar archivo: #{e.message}" }, status: :internal_server_error
    end
  end
  
  # POST /api/upload/news
  def news
    if params[:file].blank?
      return render json: { error: 'No se proporcionó archivo' }, status: :bad_request
    end
    
    file = params[:file]
    
    # Validar tipo de archivo
    unless ['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 
            'application/vnd.ms-excel',
            'text/csv'].include?(file.content_type)
      return render json: { error: 'Tipo de archivo no soportado. Use Excel (.xlsx, .xls) o CSV' }, status: :bad_request
    end
    
    require 'roo'
    
    begin
      spreadsheet = Roo::Spreadsheet.open(file.path)
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
      errors = []
      
      (2..spreadsheet.last_row).each do |row_num|
        begin
          row_data = Hash[header.zip(spreadsheet.row(row_num))]
          
          news_attributes = {}
          column_mapping.each do |excel_column, model_field|
            news_attributes[model_field] = row_data[excel_column] if row_data[excel_column].present?
          end
          
          # Validar que al menos tenga título
          if news_attributes[:titulo].blank?
            errors << "Fila #{row_num}: Título requerido"
            next
          end
          
          News.create!(news_attributes)
          imported_count += 1
        rescue => e
          errors << "Fila #{row_num}: #{e.message}"
        end
      end
      
      response = {
        message: "Se importaron #{imported_count} noticias correctamente",
        imported_count: imported_count
      }
      
      if errors.any?
        response[:errors] = errors
        response[:warning] = "Algunas filas no pudieron ser importadas"
      end
      
      render json: response
      
    rescue => e
      render json: { error: "Error al procesar archivo: #{e.message}" }, status: :internal_server_error
    end
  end
  
  # POST /api/upload/links
  def links
    links = params[:links]
    
    if links.blank? || !links.is_a?(Array) || links.empty?
      return render json: { error: 'Se requieren links válidos' }, status: :bad_request
    end
    
    imported_count = 0
    errors = []
    
    links.each_with_index do |link, index|
      begin
        # Validar formato de URL
        unless link.match?(/\Ahttps?:\/\/.+/)
          errors << "Link #{index + 1}: Formato de URL inválido"
          next
        end
        
        # Crear noticia básica con el link
        News.create!(
          titulo: "Noticia importada #{index + 1}",
          link: link,
          tipo_publicacion: "Nota",
          fecha: Date.current,
          soporte: "Digital",
          medio: "Importado",
          seccion: "General",
          tema: "Importado",
          valoracion: "Neutral"
        )
        
        imported_count += 1
      rescue => e
        errors << "Link #{index + 1}: #{e.message}"
      end
    end
    
    response = {
      message: "Se importaron #{imported_count} links correctamente",
      imported_count: imported_count
    }
    
    if errors.any?
      response[:errors] = errors
      response[:warning] = "Algunos links no pudieron ser importados"
    end
    
    render json: response
  end
end 