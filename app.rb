require_relative './api/security/sha'
require_relative './api/security/cookies'
require_relative './api/accounts/accounts'
require_relative './api/licenses/licenses'

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

  # Performs actions like delete or change based on URL parameters.
  # @route GET /action/:action/:id
  # @param [String] action The action to perform ('delete' or 'change').
  # @param [Integer] id The ID of the account to modify.
  # @return [String] Confirmation message or redirect.
  get '/action/:action/:id' do
    acc = Accounts.new
    action = params[:action]
    id = params[:id]

    p action
    case action
    when "delete" then
      "Delete #{id} from db"
      if request.cookies["THOMASCOOKIE"] then
        THOMASCOOKIE = request.cookies["THOMASCOOKIE"]
        auth_res = acc.auth_token(THOMASCOOKIE)
        if auth_res == :VALID then
          licenses = Licenses.new(THOMASCOOKIE)
          licenses.delete_license(id)
        end
      end
    when "change" then
      if request.cookies["THOMASCOOKIE"] then
        THOMASCOOKIE = request.cookies["THOMASCOOKIE"]
        auth_res = acc.auth_token(THOMASCOOKIE)
        if auth_res == :VALID then
          acc.change_password_by_cookie(THOMASCOOKIE, id)
        end
      end
    end
    redirect '/'
  end

  # Generates licenses based on provided parameters.
  # @route GET /action/:action/:id/:optional
  # @param [String] action The action to perform ('generate').
  # @param [Integer] id The ID of the account for license generation.
  # @param [String] optional Optional parameter used in license generation.
  # @return [Redirect] Redirects to the home page.
  get '/action/:action/:id/:optional/:exp' do
    acc = Accounts.new
    action = params[:action]
    id = params[:id]
    exp = params[:exp]
    case action
    when "generate" then
      if request.cookies["THOMASCOOKIE"] then
        THOMASCOOKIE = request.cookies["THOMASCOOKIE"]
        auth_res = acc.auth_token(THOMASCOOKIE)
        if auth_res == :VALID then
          licenses = Licenses.new(THOMASCOOKIE)
          licenses.generate_licenses(params[:optional], params[:id].to_i, exp)
        end
      end
    end
    redirect '/'
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
        return erb :licenses
      elsif auth_res == :EXPIRED then
        # Handle expired token if needed
      end
    end
    erb :index
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
        return erb :indexv2
      elsif auth_res == :EXPIRED then
        # Handle expired token if needed
      end
    end
    erb :index
  end
end
