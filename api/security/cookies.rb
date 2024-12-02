require 'jwt'

class Cookies
    SERVER_SECRET = 'KiGenNmr1'
    def initialize() end

    def create_cookie(payload)
        JWT.encode(
            payload, 
            SERVER_SECRET, 
            'HS256', 
            { 
                exp: Time.now.to_i + (60 * 5), # 5 minutes
                sub: "KiGen" # watermark
            }
        )
    end

    def decode_cookie(payload)
        return JWT.decode(payload, SERVER_SECRET, true, { algorithm: 'HS256' })[1]
    end

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