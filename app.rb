require_relative './api/security/sha'
require_relative './api/security/cookies'
require_relative './api/accounts/accounts'
class App < Sinatra::Base
    get '/' do
        sha = SHA.new
        cookies = Cookies.new
        acc = Accounts.new

        # Skapa konto
        #print("Create account: #{acc.create("https.kiko@gmail.com", "unknownfrome", "password")}\n")

        # Logga in i konto
        #print("Auth: #{acc.authenticate("https.kiko@gmail.com", "password")}\n")

        acc.auth_token("eyJleHAiOjE3MzMxNDQzNTMsInN1YiI6IktpR2VuIiwiYWxnIjoiSFMyNTYifQ.ImE1MzdmYzQ4MWM4N2ZlYzYzNTJjN2Y1MzgyYjUwNGE3ZDkwZmFiNWNmNWM2MDYwMGUzMTA2NTEzOTY1NzViZWMi._lJPBcRy8PyiWKYclQhMLq0QBz4TGgt-4eXAhYbTew4")

        erb(:"index")
    end
end
