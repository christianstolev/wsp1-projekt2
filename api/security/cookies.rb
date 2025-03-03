require 'jwt'

# This class handles creation, decoding, and validation of JWT cookies.
class Cookies
  # Secret key used for signing JWT tokens.
  SERVER_SECRET = 'KiGenNmr1'

  # Initializes the Cookies class.
  def initialize() end

  # Creates a JWT cookie with the provided payload.
  # @param [Hash] payload The data to encode into the cookie.
  # @return [String] The encoded JWT token.
  def create_cookie(payload)
    JWT.encode(
      payload, 
      SERVER_SECRET, 
      'HS256', 
      { 
        exp: Time.now.to_i + (60 * 15), # 15 minutes expiration
        sub: "KiGen" # watermark
      }
    )
  end

  # Decodes the provided JWT token.
  # @param [String] payload The encoded JWT token.
  # @return [Hash] The decoded payload of the JWT token.
  def decode_cookie(payload)
    return JWT.decode(payload, SERVER_SECRET, true, { algorithm: 'HS256' })[1]
  end

  # Checks if the JWT token has expired.
  # @param [Hash] decrypted_payload The decoded JWT payload.
  # @return [Symbol] :VALID if the token is not expired, :EXPIRED if it has expired, :INVALID if there's no expiration.
  def check_expiration(decrypted_payload)
    # Extract payload
    payload = decrypted_payload
    if payload['exp'] then 
      expiration_time = Time.at(payload['exp'])
      
      if expiration_time < Time.now
        return :EXPIRED
      else
        return :VALID 
      end
    else
      return :INVALID
    end
  end
end
