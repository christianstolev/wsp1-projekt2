require 'sqlite3'

# Seeder class for initializing and populating the database with tables and data.
class Seeder

  # Seeds the database by dropping, creating, and populating the necessary tables.
  # @return [void]
  def self.seed!
    drop_tables
    create_tables
    populate_tables
  end

  # Drops the existing tables 'Authentication' and 'Licenses' from the database.
  # @return [void]
  def self.drop_tables
    db.execute('DROP TABLE IF EXISTS Authentication')
    db.execute('DROP TABLE IF EXISTS Licenses')
  end

  # Creates the 'Authentication' and 'Licenses' tables in the database.
  # @return [void]
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

  # Populates the 'Authentication' and 'Licenses' tables with initial data.
  # @return [void]
  def self.populate_tables
    db.execute('INSERT INTO Authentication (email, username, password, last_login) VALUES ("https.kiko@gmail.com", "pinkflamingo", "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8", CURRENT_TIMESTAMP)')
    db.execute('INSERT INTO Licenses (owner, license, product, expiration) VALUES (1, "6504-26E6-E913-AAE7", "TEST", CURRENT_TIMESTAMP)')
  end

  private
  # Returns the SQLite3 database connection object, establishing it if necessary.
  # @return [SQLite3::Database] The database connection object.
  def self.db
    return @db if @db
    @db = SQLite3::Database.new('database.sqlite')
    @db.results_as_hash = true
    @db
  end
end

Seeder.seed!
