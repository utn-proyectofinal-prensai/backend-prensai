class Api::UsersController < ApplicationController
  include JwtAuthenticatable
  
  before_action :authenticate_user!, except: [:login]
  
  # POST /api/auth/login
  def login
    user = User.find_by(email: params[:email])
    
    if user&.authenticate(params[:password])
      token = generate_jwt_token(user)
      render json: {
        message: 'Login exitoso',
        token: token,
        user: {
          id: user.id,
          email: user.email,
          role: user.role
        }
      }
    else
      render json: { error: 'Credenciales invalidas' }, status: :unauthorized
    end
  end
  
  # POST /api/auth/logout
  def logout
    # En JWT, el logout se maneja del lado del cliente eliminando el token
    render json: { message: 'Logout exitoso' }
  end
  
  # GET /api/auth/me
  def me
    render json: {
      user: {
        id: @current_user.id,
        email: @current_user.email,
        role: @current_user.role
      }
    }
  end
end
