require 'sqlite3'

class Seeder
  
  def self.seed!
    drop_tables
    create_tables
    populate_tables
  end

  def self.drop_tables
    db.execute('DROP TABLE IF EXISTS Authentication')
    db.execute('DROP TABLE IF EXISTS Licenses')
  end

  def self.create_tables
    db.execute('CREATE TABLE Authentication (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                email TEXT NOT NULL,
                username TEXT NOT NULL,
                password TEXT NOT NULL,
                last_login DATETIME,
                cookie TEXT)')
    db.execute('CREATE TABLE Licenses (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                owner INTEGER NOT NULL,
                license TEXT NOT NULL,
                product TEXT NOT NULL,
                expiration DATETIME)')
  end

  def self.populate_tables
    #db.execute('INSERT INTO Authentication (email, username, password, last_login) VALUES ("https.kiko@gmail.com", "pinkflamingo", "hashed_passwd", CURRENT_TIMESTAMP)')
  end

  private
  def self.db
    return @db if @db
    @db = SQLite3::Database.new('database.sqlite')
    @db.results_as_hash = true
    @db
  end
end


Seeder.seed!