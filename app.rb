require_relative './api/security/sha'
require_relative './api/security/cookies'
require_relative './api/accounts/accounts'
require_relative './api/licenses/licenses'

require 'rack/attack'

use Rack::Attack

Rack::Attack.throttle('req/ip', limit: 5, period: 1) do |req|
  req.ip # Throttle requests based on IP address
end

# Main application class handling various routes and actions.
class App < Sinatra::Base

  # Handles login functionality.
  # @route POST /login
  # @param [String] email User's email.
  # @param [String] password User's password.
  # @return [Redirect] Redirects to the home page.
  post '/login' do
    email = params[:email]
    password = params[:password]

    acc = Accounts.new
    status, cookie = acc.authenticate(email, password)

    if status == :SUCCESS then
      response.set_cookie('THOMASCOOKIE', value: cookie, path: '/', max_age: '3600') 
    end
    redirect '/'
  end


  post '/licenses/generate' do
    acc = Accounts.new

    amount = params[:amount].to_i
    product = params[:product]
    expiration = params[:expiration]

    if request.cookies["THOMASCOOKIE"] then
      THOMASCOOKIE = request.cookies["THOMASCOOKIE"]
      auth_res = acc.auth_token(THOMASCOOKIE)
      if auth_res == :VALID then
        licenses = Licenses.new(THOMASCOOKIE)
        licenses.generate_licenses(product, amount, expiration)
        redirect request.path
      end
    end
  end
  # Handles user registration.
  # @route POST /register
  # @param [String] email User's email.
  # @param [String] username User's username.
  # @param [String] password User's password.
  # @return [Redirect] Redirects to the home page.
  post '/register' do
    acc = Accounts.new
    email = params[:email]
    username = params[:username]
    password = params[:password]

    status = acc.create(email, username, password)
    if status == :SUCCESS then
      acc = Accounts.new
      status, cookie = acc.authenticate(email, password)
      
      p status, cookie
      if status == :SUCCESS then
        response.set_cookie('THOMASCOOKIE', value: cookie, path: '/', max_age: '3600') 
      end
      redirect '/'
    end
  end

  # Handles user logout functionality.
  # @route GET /logout
  # @return [Redirect] Redirects to the home page.
  get '/logout' do
    if request.cookies["THOMASCOOKIE"] then
      response.delete_cookie("THOMASCOOKIE")
    end
    redirect '/'
  end

  get '/terminate_account' do
    if request.cookies["THOMASCOOKIE"] then
      THOMASCOOKIE = request.cookies["THOMASCOOKIE"]
      acc = Accounts.new
      acc.delete_account(THOMASCOOKIE)
    end
    redirect '/'
  end

  get '/credits/add/:id/:amount' do
    acc = Accounts.new
    amount = params[:amount].to_i
    id = params[:id].to_i

    if request.cookies["THOMASCOOKIE"] then
      THOMASCOOKIE = request.cookies["THOMASCOOKIE"]
      auth_res = acc.auth_token(THOMASCOOKIE)
      if auth_res == :VALID then
        acc.add_credits(THOMASCOOKIE, id, amount)
        redirect '/tokens'
      end
    end
  end

  get '/credits/remove/:id/:amount' do
    acc = Accounts.new
    amount = params[:amount].to_i
    id = params[:id].to_i

    if request.cookies["THOMASCOOKIE"] then
      THOMASCOOKIE = request.cookies["THOMASCOOKIE"]
      auth_res = acc.auth_token(THOMASCOOKIE)
      if auth_res == :VALID then
        acc.remove_credits(THOMASCOOKIE, id, amount)
        redirect '/tokens'
      end
    end
  end

  get '/licenses/:id/delete' do
    acc = Accounts.new
    id = params[:id]

    "Delete #{id} from db"
    if request.cookies["THOMASCOOKIE"] then
      THOMASCOOKIE = request.cookies["THOMASCOOKIE"]
      auth_res = acc.auth_token(THOMASCOOKIE)
      if auth_res == :VALID then
        licenses = Licenses.new(THOMASCOOKIE)
        licenses.delete_license(id)
        redirect '/licenses'
      end
    end
  end

  get '/accounts/:id/change_passwords' do
    acc = Accounts.new
    id = params[:id]
    if request.cookies["THOMASCOOKIE"] then
      THOMASCOOKIE = request.cookies["THOMASCOOKIE"]
      auth_res = acc.auth_token(THOMASCOOKIE)
      if auth_res == :VALID then
        acc.change_password_by_cookie(THOMASCOOKIE, id)
      end
    end
  end

  get '/licenses' do
    sha = SHA.new
    cookies = Cookies.new
    acc = Accounts.new

    if params["register"] then
      return erb :register
    end

    if request.cookies["THOMASCOOKIE"] then
      THOMASCOOKIE = request.cookies["THOMASCOOKIE"]
      auth_res = acc.auth_token(THOMASCOOKIE)

      if auth_res == :VALID then
        licenses = Licenses.new(THOMASCOOKIE)
        @licenses = licenses.get_licenses
        @user_info = acc.get_info(THOMASCOOKIE)
        return erb :"licenses/index"
      elsif auth_res == :EXPIRED then
        # Handle expired token if needed
      end
    end
    erb :index
  end

  get '/tokens' do
    sha = SHA.new
    cookies = Cookies.new
    acc = Accounts.new
    puts "hiii"
    if request.cookies["THOMASCOOKIE"] then
      THOMASCOOKIE = request.cookies["THOMASCOOKIE"]
      auth_res = acc.auth_token(THOMASCOOKIE)
      puts auth_res
      if auth_res == :VALID then
        user_accounts = acc.get_user_accounts()
        @user_accounts = user_accounts
        @user_info = acc.get_info(THOMASCOOKIE)
        return erb :"tokens/index"
      else
        puts "auth not valid"
      end
    else
      puts "no cookie :("
    end
    puts "ded"
  end

  get '/groups/:id/join' do
    sha = SHA.new
    cookies = Cookies.new
    acc = Accounts.new

    group_id = params[:id]

    if request.cookies["THOMASCOOKIE"] then
      THOMASCOOKIE = request.cookies["THOMASCOOKIE"]
      auth_res = acc.auth_token(THOMASCOOKIE)
      puts auth_res
      if auth_res == :VALID then
        acc.join_group(THOMASCOOKIE, group_id)
        redirect '/groups'
      end
    end
  end

  
  get '/groups/:id/leave' do
    sha = SHA.new
    cookies = Cookies.new
    acc = Accounts.new

    group_id = params[:id]

    if request.cookies["THOMASCOOKIE"] then
      THOMASCOOKIE = request.cookies["THOMASCOOKIE"]
      auth_res = acc.auth_token(THOMASCOOKIE)
      puts auth_res
      if auth_res == :VALID then
        acc.leave_group(THOMASCOOKIE, group_id)
        redirect '/groups'
      end
    end
  end
  
  get '/groups' do
    sha = SHA.new
    cookies = Cookies.new
    acc = Accounts.new
    puts "hiii"
    if request.cookies["THOMASCOOKIE"] then
      THOMASCOOKIE = request.cookies["THOMASCOOKIE"]
      auth_res = acc.auth_token(THOMASCOOKIE)
      puts auth_res
      if auth_res == :VALID then
        @user_info = acc.get_info(THOMASCOOKIE)
        @groups = acc.get_user_groups(THOMASCOOKIE)
        p @groups.inspect
        return erb :"groups/index"
      else
        puts "auth not valid"
      end
    else
      puts "no cookie :("
    end
    puts "ded"
  end
  # Displays the homepage or user dashboard depending on authentication status.
  # @route GET /
  # @return [String] HTML content for the homepage or user dashboard.
  get '/' do
    sha = SHA.new
    cookies = Cookies.new
    acc = Accounts.new

    if params["register"] then
      return erb :register
    end

    if request.cookies["THOMASCOOKIE"] then
      THOMASCOOKIE = request.cookies["THOMASCOOKIE"]
      auth_res = acc.auth_token(THOMASCOOKIE)

      if auth_res == :VALID then
        licenses = Licenses.new(THOMASCOOKIE)
        @licenses = licenses.get_licenses
        @user_info = acc.get_info(THOMASCOOKIE)
        return erb :"dashboard/index"
      elsif auth_res == :EXPIRED then
        # Handle expired token if needed
      end
    end
    erb :index
  end
end
