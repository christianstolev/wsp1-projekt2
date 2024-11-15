require 'sqlite3'
class Database
    attr_reader :db
    def initialize()
        @db = SQLite3::Database.new("database.sqlite")
        @db.results_as_hash = true
    end

    def execute(query, args)
        p query
        p args
        @db.execute(query, args)
    end

    def changes()
        @db.changes 
    end
end