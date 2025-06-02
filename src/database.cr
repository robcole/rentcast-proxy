require "sqlite3"
require "json"

module RentcastProxy
  class Database
    DB_PATH = "cache.db"

    def self.initialize_db
      db = DB.open("sqlite3://#{DB_PATH}")
      create_cache_table(db)
      create_indexes(db)
      db.close
    end

    private def self.create_cache_table(db)
      db.exec <<-SQL
        CREATE TABLE IF NOT EXISTS cache (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          endpoint TEXT NOT NULL,
          query_params TEXT NOT NULL,
          response_body TEXT NOT NULL,
          status_code INTEGER NOT NULL,
          created_at INTEGER NOT NULL,
          expires_at INTEGER NOT NULL,
          UNIQUE(endpoint, query_params)
        )
      SQL
    end

    private def self.create_indexes(db)
      db.exec "CREATE INDEX IF NOT EXISTS idx_cache_endpoint_params ON cache(endpoint, query_params)"
      db.exec "CREATE INDEX IF NOT EXISTS idx_cache_expires_at ON cache(expires_at)"
    end

    def self.get_cached_response(endpoint : String, query_params : String)
      db = DB.open("sqlite3://#{DB_PATH}")
      result = query_cached_data(db, endpoint, query_params)
      db.close
      result
    end

    private def self.query_cached_data(db, endpoint, query_params)
      current_time = Time.utc.to_unix
      db.query_one?(
        "SELECT response_body, status_code FROM cache WHERE endpoint = ? AND query_params = ? AND expires_at > ?",
        endpoint, query_params, current_time
      ) { |row| {response_body: row.read(String), status_code: row.read(Int32)} }
    end

    def self.cache_response(endpoint : String,
                            query_params : String,
                            response_body : String,
                            status_code : Int32,
                            ttl_seconds : Int32 = 604800)
      return if status_code >= 400
      db = DB.open("sqlite3://#{DB_PATH}")
      insert_cache_entry(db, endpoint, query_params, response_body, status_code, ttl_seconds)
      db.close
    end

    private def self.insert_cache_entry(db, endpoint, query_params, response_body, status_code, ttl_seconds)
      current_time = Time.utc.to_unix
      expires_at = current_time + ttl_seconds
      db.exec("INSERT OR REPLACE INTO cache (endpoint, query_params, response_body, status_code, created_at, expires_at) VALUES (?, ?, ?, ?, ?, ?)",
        endpoint, query_params, response_body, status_code, current_time, expires_at)
    end

    def self.cleanup_expired_cache
      db = DB.open("sqlite3://#{DB_PATH}")
      db.exec("DELETE FROM cache WHERE expires_at <= ?", Time.utc.to_unix)
      db.close
    end
  end
end
