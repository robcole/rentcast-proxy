require "http/client"
require "json"
require "./models"
require "./database"
require "./cache_manager"

module RentcastProxy
  class Client
    BASE_URL    = "https://api.rentcast.io/v1"
    DEFAULT_TTL = 604800

    def initialize(@api_key : String)
    end

    def get_properties(params : Hash(String, String))
      get_with_cache("/properties", build_query_string(params)) do
        make_request("/properties", params)
      end
    end

    def get_property_by_id(id : String)
      endpoint = "/properties/#{id}"
      get_with_cache(endpoint, "") do
        make_request_by_path(endpoint)
      end
    end

    def get_rent_estimate(params : Hash(String, String))
      get_with_cache("/avm/rent/long-term", build_query_string(params)) do
        make_request("/avm/rent/long-term", params)
      end
    end

    def get_value_estimate(params : Hash(String, String))
      get_with_cache("/avm/value", build_query_string(params)) do
        make_request("/avm/value", params)
      end
    end

    private def get_with_cache(endpoint : String, query_string : String, &)
      if cached = Database.get_cached_response(endpoint, query_string)
        return build_cached_response(cached)
      end
      response = yield
      CacheManager.cache_with_ttl(endpoint, query_string, response.body, response.status_code, DEFAULT_TTL)
      build_fresh_response(response)
    end

    private def build_cached_response(cached)
      {body: cached[:response_body], status_code: cached[:status_code], from_cache: true}
    end

    private def build_fresh_response(response)
      {body: response.body, status_code: response.status_code, from_cache: false}
    end

    private def make_request(endpoint : String, params : Hash(String, String))
      query_string = build_query_string(params)
      full_path = "#{endpoint}?#{query_string}"

      make_request_by_path(full_path)
    end

    private def make_request_by_path(path : String)
      headers = HTTP::Headers{
        "X-Api-Key" => @api_key,
        "Accept"    => "application/json",
      }

      HTTP::Client.get("#{BASE_URL}#{path}", headers: headers)
    end

    private def build_query_string(params : Hash(String, String))
      params.map { |k, v| "#{k}=#{URI.encode_www_form(v)}" }.join("&")
    end
  end
end
