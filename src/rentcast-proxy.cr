require "kemal"
require "colorize"
require "./database"
require "./proxy"
require "./cache_manager"

module RentcastProxy
  class Application
    def self.start
      puts "Starting Rentcast API Proxy...".colorize(:green).bold

      api_key = ENV["RENTCAST_API_KEY"]?
      if api_key.nil? || api_key.empty?
        puts "Error: RENTCAST_API_KEY environment variable is required".colorize(:red).bold
        exit(1)
      end

      initialize_database
      start_cache_cleanup
      setup_server(api_key)

      puts "Rentcast API Proxy started on http://localhost:3000".colorize(:green).bold
      Kemal.run
    end

    private def self.initialize_database
      puts "Initializing database...".colorize(:blue).bold
      Database.initialize_db
      puts "Database initialized successfully".colorize(:green).bold
    end

    private def self.start_cache_cleanup
      puts "Starting cache cleanup scheduler...".colorize(:blue).bold
      CacheManager.start_cleanup_scheduler
      puts "Cache cleanup scheduler started".colorize(:green).bold
    end

    private def self.setup_server(api_key : String)
      proxy = Proxy.new(api_key)
      proxy.setup_routes

      Kemal.config.port = 3000
      Kemal.config.env = "production"

      before_all do |env|
        env.response.headers["Access-Control-Allow-Origin"] = "*"
        env.response.headers["Access-Control-Allow-Methods"] = "GET, OPTIONS"
        env.response.headers["Access-Control-Allow-Headers"] = "Content-Type"
      end
    end
  end
end

RentcastProxy::Application.start
