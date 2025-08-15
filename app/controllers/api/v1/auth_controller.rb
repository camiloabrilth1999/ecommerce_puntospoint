class Api::V1::AuthController < ApplicationController
  include JwtAuthentication

  skip_before_action :authenticate_administrator!, only: [ :login ]
  def login
    administrator = Administrator.find_by(email: login_params[:email])

    if administrator&.authenticate(login_params[:password]) && administrator.active?
      token = JwtService.generate_token(administrator)

      render json: {
        success: true,
        token: token,
        administrator: {
          id: administrator.id,
          name: administrator.name,
          email: administrator.email,
          role: administrator.role
        }
      }, status: :ok
    else
      render json: {
        success: false,
        error: "Invalid credentials or inactive account"
      }, status: :unauthorized
    end
  end

  def validate
    render json: {
      success: true,
      administrator: {
        id: @current_administrator.id,
        name: @current_administrator.name,
        email: @current_administrator.email,
        role: @current_administrator.role
      }
    }, status: :ok
  end

  def logout
    # JWT tokens are stateless, so logout is handled on the client side
    render json: {
      success: true,
      message: "Logged out successfully"
    }, status: :ok
  end

  private

  def login_params
    params.require(:administrator).permit(:email, :password)
  end
end
