require 'sqlite3'

# This class handles database interactions using SQLite3.
class Database
  attr_reader :db

  # Initializes the Database class and establishes a connection to the SQLite3 database.
  # @return [void]
  def initialize()
    @db = SQLite3::Database.new("database.sqlite")
    @db.results_as_hash = true
  end

  # Executes a given SQL query with provided arguments.
  # @param [String] query The SQL query to execute.
  # @param [Array] args The arguments to bind to the query.
  # @return [Array] The result of the query.
  def execute(query, args=[])
    @db.execute(query, args)
  end

  # Returns the number of rows affected by the last SQL operation.
  # @return [Integer] The number of rows changed by the last query.
  def changes()
    @db.changes
  end
end
