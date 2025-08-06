class Api::TestController < ApplicationController
  def index
    render json: { message: 'API funcionando correctamente' }
  end
  
  def news
    render json: { news: News.all }
  end
  
  def stats
    render json: { 
      total: News.count,
      message: 'Stats funcionando'
    }
  end
  
  def login_test
    user = User.find_by(email: params[:email])
    
    if user&.authenticate(params[:password])
      render json: {
        message: 'Login exitoso',
        user: {
          id: user.id,
          email: user.email,
          role: user.role
        }
      }
    else
      render json: { error: 'Credenciales inválidas' }, status: :unauthorized
    end
  end
end 