require_relative './api/security/sha'
require_relative './api/security/cookies'
class App < Sinatra::Base
    get '/' do
        sha = SHA.new
        cookies = Cookies.new
        p cookies.create_cookie(sha.hash_str("Hi"))
        erb(:"index")
    end
end
