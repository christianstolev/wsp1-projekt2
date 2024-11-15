require_relative '../security/sha'
require_relative '../security/cookies'
require_relative '../db/db'
class Accounts
    attr_reader :sha, :db, :cookies

    Status = {
        SUCCESS: 1,
        FAILED: 2,
        EMAIL_EXISTS: 3,
        USERNAME_EXISTS: 4,
        ERROR: 9
    }

    def initialize()
        @sha = SHA.new
        @db = Database.new
        @cookies = Cookies.new
    end
    def create(email, username, password)
        email_exists = db.execute('SELECT 1 FROM Authentication WHERE email = ?', [email]).any?
      
        username_exists = db.execute('SELECT 1 FROM Authentication WHERE username = ?', [username]).any?
      
        if email_exists
          return Status[:EMAIL_EXISTS]
        elsif username_exists
            return Status[:USERNAME_EXISTS]
        else
          hashed_password = sha.hash_str(password)
          db.execute('INSERT INTO Authentication (email, username, password, last_login) VALUES (?, ?, ?, CURRENT_TIMESTAMP)', [email, username, hashed_password])
      
          return Status[:SUCCESS]
        end
    end      

    def authenticate(email, password)
        hashed_password = sha.hash_str(password)
        jwt_token = @cookies.create_cookie(@sha.hash_str(email))
        db.execute('UPDATE Authentication SET cookie = ?, last_login = CURRENT_TIMESTAMP WHERE email = ? AND password = ?', [jwt_token, email, hashed_password])
        rows_affected = db.changes 
        if rows_affected > 0 then
            return Status[:SUCCESS], jwt_token
        else
            return Status[:FAILED], "FAILED TO AUTHENTICATE."
        end
    end
end