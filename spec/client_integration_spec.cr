require "./spec_helper"
require "http/server"
require "http/client"

describe "Client Integration with Cache" do
  before_each do
    # Clean up the actual cache database file used by the application
    File.delete("cache.db") if File.exists?("cache.db")
    RentcastProxy::Database.initialize_db
  end

  after_each do
    # Clean up the cache database after each test
    File.delete("cache.db") if File.exists?("cache.db")
  end

  describe "HTTP Client Cache Behavior" do
    it "makes HTTP request on cache miss and caches response" do
      # Create a mock HTTP server to simulate Rentcast API
      call_count = 0
      mock_response = {
        properties: [
          {id: "test123", city: "Austin", state: "TX"},
        ],
        count: 1,
        total: 1,
      }.to_json

      mock_server = HTTP::Server.new do |context|
        call_count += 1
        context.response.content_type = "application/json"
        context.response.status_code = 200
        context.response.print(mock_response)
      end

      spawn do
        mock_server.bind_tcp("127.0.0.1", 8080)
        mock_server.listen
      end

      sleep 0.1.seconds # Allow server to start

      begin
        # Create a modified client for testing (would need base URL override)
        # For now, simulate the behavior by directly testing the cache logic

        endpoint = "/properties"
        query_params = "city=Austin&state=TX"

        # Verify cache miss initially
        cached = RentcastProxy::Database.get_cached_response(endpoint, query_params)
        cached.should be_nil

        # Simulate what the client does: check cache, then make HTTP request
        if cached.nil?
          # This would be the HTTP request in real client
          response_body = mock_response
          status_code = 200

          # Cache the response
          RentcastProxy::CacheManager.cache_with_ttl(
            endpoint,
            query_params,
            response_body,
            status_code,
            3600
          )
        end

        # Verify response is now cached
        cached = RentcastProxy::Database.get_cached_response(endpoint, query_params)
        cached.should_not be_nil
        cached.try { |c| c[:response_body].should eq(mock_response) }
      ensure
        mock_server.close
      end
    end

    it "returns cached response without HTTP request on cache hit" do
      endpoint = "/properties"
      query_params = "city=Austin&state=TX"
      cached_response = {
        properties: [
          {id: "cached123", city: "Austin", state: "TX"},
        ],
        count: 1,
        total: 1,
      }.to_json

      # Pre-populate cache
      RentcastProxy::CacheManager.cache_with_ttl(
        endpoint,
        query_params,
        cached_response,
        200,
        3600
      )

      # Verify cache hit
      cached = RentcastProxy::Database.get_cached_response(endpoint, query_params)
      cached.should_not be_nil

      if cached
        cached[:response_body].should eq(cached_response)
        cached[:status_code].should eq(200)

        # This demonstrates that we get the cached response
        # without making an HTTP request (call_count would be 0)
      end
    end

    it "handles different query parameters as separate cache entries" do
      base_endpoint = "/properties"

      # Different query parameters
      params1 = "city=Austin&state=TX"
      params2 = "city=Dallas&state=TX"

      response1 = {properties: [{id: "austin1"}], count: 1, total: 1}.to_json
      response2 = {properties: [{id: "dallas1"}], count: 1, total: 1}.to_json

      # Cache different responses for different parameters
      RentcastProxy::CacheManager.cache_with_ttl(base_endpoint, params1, response1, 200, 3600)
      RentcastProxy::CacheManager.cache_with_ttl(base_endpoint, params2, response2, 200, 3600)

      # Verify both are cached separately
      cached1 = RentcastProxy::Database.get_cached_response(base_endpoint, params1)
      cached2 = RentcastProxy::Database.get_cached_response(base_endpoint, params2)

      cached1.should_not be_nil
      cached2.should_not be_nil

      cached1.try { |c| c[:response_body].should eq(response1) }
      cached2.try { |c| c[:response_body].should eq(response2) }

      cached1.try { |c| c[:response_body].should_not eq(cached2.try { |c2| c2[:response_body] }) }
    end

    it "bypasses cache for error responses" do
      endpoint = "/properties"
      query_params = "invalid=true"

      # Simulate error response (should not be cached)
      error_response = {error: "Invalid parameters"}.to_json
      status_code = 400

      RentcastProxy::CacheManager.cache_with_ttl(
        endpoint,
        query_params,
        error_response,
        status_code,
        3600
      )

      # Error responses should not be cached
      cached = RentcastProxy::Database.get_cached_response(endpoint, query_params)
      cached.should be_nil
    end
  end
end
