require "kemal"
require "colorize"
require "./client"
require "./models"

module RentcastProxy
  class Proxy
    def initialize(@api_key : String)
      @client = Client.new(@api_key)
    end

    def setup_routes
      get "/v1/properties" do |env|
        handle_properties_request(env)
      end

      get "/v1/properties/:id" do |env|
        handle_property_by_id_request(env)
      end

      get "/v1/avm/rent/long-term" do |env|
        handle_rent_estimate_request(env)
      end

      get "/v1/avm/value" do |env|
        handle_value_estimate_request(env)
      end

      get "/health" do |env|
        env.response.content_type = "application/json"
        {status: "healthy", timestamp: Time.utc.to_rfc3339}.to_json
      end

      error 404 do |env|
        env.response.content_type = "application/json"
        env.response.status_code = 404
        {error: "Not Found", message: "The requested endpoint was not found"}.to_json
      end

      error 500 do |env|
        env.response.content_type = "application/json"
        env.response.status_code = 500
        {error: "Internal Server Error", message: "An unexpected error occurred"}.to_json
      end
    end

    private def handle_properties_request(env)
      params = extract_query_params(env)
      handle_client_request(env) { @client.get_properties(params) }
    end

    private def handle_property_by_id_request(env)
      id = env.params.url["id"]
      handle_client_request(env) { @client.get_property_by_id(id) }
    end

    private def handle_rent_estimate_request(env)
      params = extract_query_params(env)
      handle_client_request(env) { @client.get_rent_estimate(params) }
    end

    private def handle_value_estimate_request(env)
      params = extract_query_params(env)
      handle_client_request(env) { @client.get_value_estimate(params) }
    end

    private def handle_client_request(env, &)
      result = yield
      set_response_headers(env, result)
      result[:body]
    rescue ex : Exception
      handle_error(env, ex)
    end

    private def set_response_headers(env, result)
      env.response.content_type = "application/json"
      env.response.status_code = result[:status_code]
      env.response.headers["X-Cache"] = result[:from_cache] ? "HIT" : "MISS"
    end

    private def extract_query_params(env)
      params = {} of String => String
      env.request.query_params.each { |key, value| params[key] = value }
      params
    end

    private def handle_error(env, ex : Exception)
      puts "Error processing request: #{ex.message}".colorize(:red).bold
      env.response.content_type = "application/json"
      env.response.status_code = 500
      {error: "Internal Server Error", message: ex.message}.to_json
    end
  end
end
