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
      endpoint = "/properties"
      query_string = build_query_string(params)

      if cached = Database.get_cached_response(endpoint, query_string)
        return {
          body:        cached[:response_body],
          status_code: cached[:status_code],
          from_cache:  true,
        }
      end

      response = make_request(endpoint, params)

      CacheManager.cache_with_ttl(
        endpoint,
        query_string,
        response.body,
        response.status_code,
        DEFAULT_TTL
      )

      {
        body:        response.body,
        status_code: response.status_code,
        from_cache:  false,
      }
    end

    def get_property_by_id(id : String)
      endpoint = "/properties/#{id}"
      query_string = ""

      if cached = Database.get_cached_response(endpoint, query_string)
        return {
          body:        cached[:response_body],
          status_code: cached[:status_code],
          from_cache:  true,
        }
      end

      response = make_request_by_path(endpoint)

      CacheManager.cache_with_ttl(
        endpoint,
        query_string,
        response.body,
        response.status_code,
        DEFAULT_TTL
      )

      {
        body:        response.body,
        status_code: response.status_code,
        from_cache:  false,
      }
    end

    def get_rent_estimate(params : Hash(String, String))
      endpoint = "/avm/rent/long-term"
      query_string = build_query_string(params)

      if cached = Database.get_cached_response(endpoint, query_string)
        return {
          body:        cached[:response_body],
          status_code: cached[:status_code],
          from_cache:  true,
        }
      end

      response = make_request(endpoint, params)

      CacheManager.cache_with_ttl(
        endpoint,
        query_string,
        response.body,
        response.status_code,
        DEFAULT_TTL
      )

      {
        body:        response.body,
        status_code: response.status_code,
        from_cache:  false,
      }
    end

    def get_value_estimate(params : Hash(String, String))
      endpoint = "/avm/value"
      query_string = build_query_string(params)

      if cached = Database.get_cached_response(endpoint, query_string)
        return {
          body:        cached[:response_body],
          status_code: cached[:status_code],
          from_cache:  true,
        }
      end

      response = make_request(endpoint, params)

      CacheManager.cache_with_ttl(
        endpoint,
        query_string,
        response.body,
        response.status_code,
        DEFAULT_TTL
      )

      {
        body:        response.body,
        status_code: response.status_code,
        from_cache:  false,
      }
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
