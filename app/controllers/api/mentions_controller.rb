class Api::MentionsController < ApplicationController
  include JwtAuthenticatable
  
  before_action :authenticate_user!
  before_action :set_mention, only: [:update, :destroy]
  
  # GET /api/mentions/all
  def index
    @mentions = ActiveMention.order(created_at: :desc)
    render json: {
      mentions: @mentions,
      total: @mentions.count
    }
  end
  
  # GET /api/mentions/active
  def active
    @active_mentions = ActiveMention.where(active: true).order(created_at: :desc)
    render json: {
      active_mentions: @active_mentions,
      total: @active_mentions.count
    }
  end
  
  # POST /api/mentions
  def create
    @mention = ActiveMention.new(mention_params)
    
    if @mention.save
      render json: {
        message: 'Mención creada exitosamente',
        mention: @mention
      }, status: :created
    else
      render json: {
        error: 'Error al crear mención',
        errors: @mention.errors.full_messages
      }, status: :unprocessable_entity
    end
  end
  
  # PUT /api/mentions/:id
  def update
    if @mention.update(mention_params)
      render json: {
        message: 'Mención actualizada exitosamente',
        mention: @mention
      }
    else
      render json: {
        error: 'Error al actualizar mención',
        errors: @mention.errors.full_messages
      }, status: :unprocessable_entity
    end
  end
  
  # DELETE /api/mentions/:id
  def destroy
    @mention.destroy
    render json: {
      message: 'Mención eliminada exitosamente'
    }
  end
  
  # PUT /api/mentions/active
  def update_active
    mention_ids = params[:mention_ids]
    
    if mention_ids.blank? || !mention_ids.is_a?(Array)
      return render json: { error: 'Se requieren IDs de menciones válidos' }, status: :bad_request
    end
    
    # Desactivar todas las menciones primero
    ActiveMention.update_all(active: false)
    
    # Activar solo las menciones seleccionadas
    ActiveMention.where(id: mention_ids).update_all(active: true)
    
    active_mentions = ActiveMention.where(active: true)
    
    render json: {
      message: 'Menciones activas actualizadas exitosamente',
      active_mentions: active_mentions,
      total: active_mentions.count
    }
  end
  
  private
  
  def set_mention
    @mention = ActiveMention.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Mención no encontrada' }, status: :not_found
  end
  
  def mention_params
    params.require(:mention).permit(:name, :description, :category, :priority, :active, :keywords)
  end
end
