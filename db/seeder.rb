require 'sqlite3'
require_relative '../api/security/sha'
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
    db.execute('DROP TABLE IF EXISTS Authentication;')
    db.execute('DROP TABLE IF EXISTS Licenses;')
    db.execute('DROP TABLE IF EXISTS UserGroups;')    
    
    db.execute('DROP TABLE IF EXISTS Groups;')
  end

  # Creates the 'Authentication' and 'Licenses' tables in the database.
  # @return [void]
  def self.create_tables
    db.execute("PRAGMA foreign_keys = ON;")
    db.execute('CREATE TABLE Authentication (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                email TEXT NOT NULL,
                username TEXT NOT NULL,
                password TEXT NOT NULL,
                credits INTEGER DEFAULT 0,
                role INTEGER DEFAULT 1,
                last_login DATETIME,
                cookie TEXT)')
    db.execute('CREATE TABLE Groups (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL
    );')

    db.execute('CREATE TABLE UserGroups (
        user_id INTEGER,
        group_id INTEGER,
        PRIMARY KEY (user_id, group_id),
        FOREIGN KEY (user_id) REFERENCES Authentication(id) ON DELETE CASCADE,
        FOREIGN KEY (group_id) REFERENCES Groups(id) ON DELETE CASCADE
    );')
    db.execute('CREATE TABLE Licenses (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                owner INTEGER NOT NULL,
                license TEXT NOT NULL,
                product TEXT NOT NULL,
                expiration DATETIME,
                FOREIGN KEY (owner) REFERENCES Authentication(id) ON DELETE CASCADE
                )')
  end

  # Populates the 'Authentication' and 'Licenses' tables with initial data.
  # @return [void]
  def self.populate_tables
    
    sha = SHA.new
    db.execute('INSERT INTO Authentication (email, username, password, credits, role, last_login) VALUES ("admin", "admin", "' + sha.hash_str("admin") + '", 50, 2, CURRENT_TIMESTAMP)')
    db.execute('INSERT INTO Authentication (email, username, password, last_login) VALUES ("christian@gmail.com", "hayz", "' + sha.hash_str("password123") + '", CURRENT_TIMESTAMP)')
    db.execute('INSERT INTO Authentication (email, username, password, last_login) VALUES ("231ersdfxc@gmail.com", "adlien", "' + sha.hash_str("password123") + '", CURRENT_TIMESTAMP)')
    db.execute('INSERT INTO Authentication (email, username, password, last_login) VALUES ("5q4yetg45qet54ge5@gmail.com", "13qeda", "' + sha.hash_str("password123") + '", CURRENT_TIMESTAMP)')
    db.execute('INSERT INTO Authentication (email, username, password, last_login) VALUES ("elliot@gmail.com", "elli9023", "' + sha.hash_str("password123") + '", CURRENT_TIMESTAMP)')
    db.execute('INSERT INTO Authentication (email, username, password, last_login) VALUES ("aker@gmail.com", "eker", "' + sha.hash_str("password123") + '", CURRENT_TIMESTAMP)')
    #db.execute('INSERT INTO Licenses (owner, license, product, expiration) VALUES (1, "6504-26E6-E913-AAE7", "TEST", "2026-02-03")')
    
    db.execute('INSERT INTO Groups(name) VALUES ("Cool Kids Club");')
    db.execute('INSERT INTO Groups(name) VALUES ("Boring Kids Club");')
    db.execute('INSERT INTO Groups(name) VALUES ("Foxtrot");')
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