require "colorize"
require "./database"

module RentcastProxy
  class CacheManager
    DEFAULT_TTL_SECONDS = 604800

    def self.start_cleanup_scheduler
      spawn do
        loop do
          sleep(3600)
          cleanup_expired_entries
        end
      end
    end

    def self.cleanup_expired_entries
      puts "Running cache cleanup...".colorize(:yellow).bold
      Database.cleanup_expired_cache
      puts "Cache cleanup completed".colorize(:green).bold
    rescue ex : Exception
      puts "Error during cache cleanup: #{ex.message}".colorize(:red).bold
    end

    def self.cache_with_ttl(endpoint : String,
                            query_params : String,
                            response_body : String,
                            status_code : Int32,
                            ttl_seconds : Int32 = DEFAULT_TTL_SECONDS)
      return if should_skip_caching?(status_code)

      Database.cache_response(
        endpoint,
        query_params,
        response_body,
        status_code,
        ttl_seconds
      )
    end

    private def self.should_skip_caching?(status_code : Int32)
      status_code >= 400
    end
  end
end
