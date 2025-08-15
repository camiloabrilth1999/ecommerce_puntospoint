class JwtService
  SECRET_KEY = Rails.application.credentials.secret_key_base || 'development_secret'
  ALGORITHM = 'HS256'.freeze

  class << self
    def encode(payload, expires_in = 24.hours)
      payload[:exp] = expires_in.from_now.to_i
      JWT.encode(payload, SECRET_KEY, ALGORITHM)
    end

    def decode(token)
      decoded_token = JWT.decode(token, SECRET_KEY, true, algorithm: ALGORITHM)
      decoded_token[0]
    rescue JWT::DecodeError, JWT::ExpiredSignature => e
      Rails.logger.error "JWT Error: #{e.message}"
      nil
    end

    def generate_token(administrator)
      payload = {
        administrator_id: administrator.id,
        email: administrator.email,
        role: administrator.role,
        iat: Time.current.to_i
      }
      encode(payload)
    end

    def verify_token(token)
      decoded_payload = decode(token)
      return nil unless decoded_payload

      administrator = Administrator.find_by(id: decoded_payload['administrator_id'])
      return nil unless administrator&.active?

      administrator
    end
  end
end
