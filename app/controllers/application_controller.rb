class ApplicationController < ActionController::API
  # Error handling
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :handle_invalid_record
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
  rescue_from StandardError, with: :handle_internal_error

  private

  def handle_not_found(exception)
    render json: {
      error: "Resource not found",
      message: exception.message
    }, status: :not_found
  end

  def handle_invalid_record(exception)
    render json: {
      error: "Validation failed",
      message: exception.message,
      details: exception.record.errors.full_messages
    }, status: :unprocessable_entity
  end

  def handle_parameter_missing(exception)
    render json: {
      error: "Missing required parameter",
      message: exception.message
    }, status: :bad_request
  end

  def handle_internal_error(exception)
    Rails.logger.error "Internal server error: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")

    render json: {
      error: "Internal server error",
      message: (Rails.env.development? || Rails.env.test?) ? exception.message : "Something went wrong"
    }, status: :internal_server_error
  end
end
