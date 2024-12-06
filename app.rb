require_relative './api/security/sha'
require_relative './api/security/cookies'
require_relative './api/accounts/accounts'
class App < Sinatra::Base
    get '/' do
        sha = SHA.new
        cookies = Cookies.new
        acc = Accounts.new

        # Skapa konto
        # Kan returnera följande: :EMAIL_EXISTS, :USERNAME_EXISTS, :SUCCESS
        acc.create("https.kiko@gmail.com", "unknownfrome", "password")

        # Logga in i konto
        status, cookie = acc.authenticate("https.kiko@gmail.com", "password")
        if status == :SUCCESS then
            p "Signed in!"
            acc.auth_token(cookie) # Returnerar :SUCCESS, :EXPIRED eller :FAILED 
        else
            p "Failed to login!"
        end
        

        erb(:"index")
    end
end
