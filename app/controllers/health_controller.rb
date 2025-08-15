class HealthController < ApplicationController
  # Simple health check endpoint
  def show
    # Basic database check
    Administrator.connection.execute("SELECT 1")

    render json: {
      status: "ok",
      timestamp: Time.current.iso8601,
      environment: Rails.env
    }
  rescue => e
    render json: {
      status: "error",
      message: e.message,
      timestamp: Time.current.iso8601
    }, status: :service_unavailable
  end
end
