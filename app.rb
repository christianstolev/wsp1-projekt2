require_relative './api/security/sha'
require_relative './api/security/cookies'
require_relative './api/accounts/accounts'
class App < Sinatra::Base

    post '/login' do
        email = params[:email]
        password = params[:password]

        acc = Accounts.new
        status, cookie = acc.authenticate(email, password)
        p "..............................."
        p status, cookie
        if status == :SUCCESS then
            response.set_cookie('THOMASCOOKIE', value: cookie, path: '/', max_age: '3600') 
            p "Set cookie"
        end
        redirect '/'
    end

    post '/register' do
        acc = Accounts.new
        email = params[:email]
        username = params[:username]
        password = params[:password]

        status = acc.create(email, username, password)
        if status == :SUCCESS then
            acc = Accounts.new
            status, cookie = acc.authenticate(email, password)
            p "..............................."
            p status, cookie
            if status == :SUCCESS then
                response.set_cookie('THOMASCOOKIE', value: cookie, path: '/', max_age: '3600') 
                p "Set cookie"
            end
            redirect '/'
        end
    end

    get '/logout' do
        if request.cookies["THOMASCOOKIE"] then
            response.delete_cookie("THOMASCOOKIE")
        end
        redirect '/'
    end

    get '/' do
        sha = SHA.new
        cookies = Cookies.new
        acc = Accounts.new
        p request.cookies


        if params["register"] then
            return erb :register
        end

        if request.cookies["THOMASCOOKIE"] then
            THOMASCOOKIE = request.cookies["THOMASCOOKIE"]
            auth_res = acc.auth_token(THOMASCOOKIE)
            p "CHECKING COOKIE BRUH"
            p auth_res
            if auth_res == :VALID then
                p "DRAWING DASHBOARD"
                return erb :dashboard
            elsif auth_res == :EXPIRED then
                p "COOKIE IS EXPIRED BRUH"
            end
        end
        erb :index
    end
end
