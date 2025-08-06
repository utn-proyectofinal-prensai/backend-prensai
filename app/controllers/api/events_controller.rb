class Api::EventsController < ApplicationController
  include JwtAuthenticatable
  
  before_action :authenticate_user!
  before_action :set_event, only: [:update, :destroy]
  
  # GET /api/events
  def index
    @events = Event.order(created_at: :desc)
    render json: {
      events: @events,
      total: @events.count
    }
  end
  
  # GET /api/events/active
  def active
    @active_events = Event.where(active: true).order(created_at: :desc)
    render json: {
      active_events: @active_events,
      total: @active_events.count
    }
  end
  
  # POST /api/events
  def create
    @event = Event.new(event_params)
    
    if @event.save
      render json: {
        message: 'Evento creado exitosamente',
        event: @event
      }, status: :created
    else
      render json: {
        error: 'Error al crear evento',
        errors: @event.errors.full_messages
      }, status: :unprocessable_entity
    end
  end
  
  # PUT /api/events/:id
  def update
    if @event.update(event_params)
      render json: {
        message: 'Evento actualizado exitosamente',
        event: @event
      }
    else
      render json: {
        error: 'Error al actualizar evento',
        errors: @event.errors.full_messages
      }, status: :unprocessable_entity
    end
  end
  
  # DELETE /api/events/:id
  def destroy
    @event.destroy
    render json: {
      message: 'Evento eliminado exitosamente'
    }
  end
  
  private
  
  def set_event
    @event = Event.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Evento no encontrado' }, status: :not_found
  end
  
  def event_params
    params.require(:event).permit(:name, :description, :start_date, :end_date, :active, :category, :priority)
  end
end
