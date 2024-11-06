require 'jwt'

class Cookies
    SERVER_SECRET = 'jwt_secret'
    def initialize() end

    def create_cookie(payload)
        JWT.encode(payload, SERVER_SECRET, 'HS256', { exp: Time.now.to_i + 60, sub: "KiGen" })
    end
end