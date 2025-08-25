class JwtAuthService
  JWT_SECRET = Rails.application.credentials.jwt_secret || ENV['JWT_SECRET'] || 'your-secret-key-here'
  JWT_ALGORITHM = 'HS256'
  
  def self.encode(payload, expiration = 24.hours.from_now)
    payload[:exp] = expiration.to_i
    JWT.encode(payload, JWT_SECRET, JWT_ALGORITHM)
  end
  
  def self.decode(token)
    begin
      decoded = JWT.decode(token, JWT_SECRET, true, { algorithm: JWT_ALGORITHM })
      decoded[0] # Return the payload
    rescue JWT::DecodeError => e
      Rails.logger.error "JWT Decode Error: #{e.message}"
      nil
    rescue JWT::ExpiredSignature => e
      Rails.logger.error "JWT Expired: #{e.message}"
      nil
    end
  end
  
  def self.valid_token?(token)
    !!decode(token)
  end
  
  # For generating tokens in your main app
  def self.generate_login_token(user)
    payload = {
      user_id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      role: user.role,
      iat: Time.current.to_i
    }
    
    encode(payload)
  end
end