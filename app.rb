require_relative './api/security/sha'
require_relative './api/security/cookies'
require_relative './api/accounts/accounts'
class App < Sinatra::Base
    get '/' do
        sha = SHA.new
        cookies = Cookies.new
        acc = Accounts.new

        # Skapa konto
        p acc.create("test@gmail.com", "username", "password")

        # Logga in i konto
        p acc.authenticate("test@gmail.com", "password")
        erb(:"index")
    end
end
