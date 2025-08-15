module JwtAuthentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_administrator!
    rescue_from UnauthorizedError, with: :handle_unauthorized
  end

  private

  def authenticate_administrator!
    token = extract_token
    raise UnauthorizedError, "Token not provided" unless token

    @current_administrator = JwtService.verify_token(token)
    raise UnauthorizedError, "Invalid or expired token" unless @current_administrator

    # Set whodunnit for PaperTrail
    PaperTrail.request.whodunnit = @current_administrator.id
  end

  def current_administrator
    @current_administrator
  end

  def extract_token
    header = request.headers["Authorization"]
    return nil unless header

    header.split(" ").last if header.start_with?("Bearer ")
  end

  def handle_unauthorized(exception)
    render json: {
      error: "Unauthorized",
      message: exception.message
    }, status: :unauthorized
  end

  class UnauthorizedError < StandardError; end
end
