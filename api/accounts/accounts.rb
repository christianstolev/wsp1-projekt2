require_relative '../security/sha'
require_relative '../security/cookies'
require_relative '../db/db'

# This class handles user authentication and account management.
class Accounts
  attr_reader :sha, :db, :cookies

  # Defines status codes for account operations.
  Status = {
    SUCCESS: 1,
    FAILED: 2,
    EMAIL_EXISTS: 3,
    USERNAME_EXISTS: 4,
    ERROR: 9
  }

  # Initializes the Accounts class with SHA, Database, and Cookies objects.
  # @return [void]
  def initialize()
    @sha = SHA.new
    @db = Database.new
    @cookies = Cookies.new
  end

  # Creates a new account with the given email, username, and password.
  # @param [String] email The email of the user.
  # @param [String] username The username of the user.
  # @param [String] password The password of the user.
  # @return [Symbol] The status of the account creation (e.g., :SUCCESS, :EMAIL_EXISTS).
  def create(email, username, password)
    email_exists = db.execute('SELECT 1 FROM Authentication WHERE email = ?', [email]).any?
    username_exists = db.execute('SELECT 1 FROM Authentication WHERE username = ?', [username]).any?

    if email_exists
      return :EMAIL_EXISTS
    elsif username_exists
      return :USERNAME_EXISTS
    else
      hashed_password = sha.hash_str(password)
      db.execute('INSERT INTO Authentication (email, username, password, last_login) VALUES (?, ?, ?, CURRENT_TIMESTAMP)', [email, username, hashed_password])
      return :SUCCESS
    end
  end

  # Authenticates the user based on the provided token.
  # @param [String] token The authentication token (cookie).
  # @return [Symbol] The authentication status (e.g., :VALID, :EXPIRED, :INVALID).
  def auth_token(token)
    token_exists = db.execute('SELECT 1 FROM Authentication WHERE cookie = ?', [token]).any?
    if token_exists
      payload = @cookies.decode_cookie(token)
      status = @cookies.check_expiration(payload)
      if status == :EXPIRED || status == :INVALID
        db.execute('UPDATE Authentication SET cookie = NULL WHERE cookie = ?', [token])
        return :EXPIRED
      end
      return :VALID
    else
      return :INVALID
    end
  end

  # Changes the user's password using a valid authentication cookie.
  # @param [String] cookie The user's authentication cookie.
  # @param [String] new_password The new password for the user.
  # @return [Symbol] The status of the password change (e.g., :SUCCESS, :INVALID).
  def change_password_by_cookie(cookie, new_password)
    token_exists = db.execute('SELECT email FROM Authentication WHERE cookie = ?', [cookie]).first
    if token_exists
      email = token_exists['email']
      hashed_password = sha.hash_str(new_password)
      db.execute('UPDATE Authentication SET password = ?, last_login = CURRENT_TIMESTAMP WHERE email = ?', [hashed_password, email])
      return :SUCCESS
    else
      return :INVALID
    end
  end

  # Authenticates the user with the provided email and password.
  # @param [String] email The email of the user.
  # @param [String] password The password of the user.
  # @return [Array<Symbol, String>] The status of authentication and the generated JWT token (if successful).
  def authenticate(email, password)
    hashed_password = sha.hash_str(password)
    jwt_token = @cookies.create_cookie(@sha.hash_str(email))
    db.execute('UPDATE Authentication SET cookie = ?, last_login = CURRENT_TIMESTAMP WHERE email = ? AND password = ?', [jwt_token, email, hashed_password])
    rows_affected = db.changes
    if rows_affected > 0
      return :SUCCESS, jwt_token
    else
      return :FAILED, "FAILED TO AUTHENTICATE."
    end
  end
end
