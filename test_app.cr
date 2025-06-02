require "./src/models"
require "./src/database"
require "./src/cache_manager"
require "colorize"

puts "Testing Rentcast Proxy Components...".colorize(:green).bold

puts "\n1. Testing Database Initialization".colorize(:blue).bold
RentcastProxy::Database.initialize_db
puts "✓ Database initialized successfully".colorize(:green)

puts "\n2. Testing Models".colorize(:blue).bold
begin
  json_data = File.read("spec/fixtures/single_property_response.json")
  property = RentcastProxy::Models::Property.from_json(json_data)
  puts "✓ Property model: #{property.id} - #{property.formatted_address}".colorize(:green)
rescue ex
  puts "✗ Model test failed: #{ex.message}".colorize(:red)
end

puts "\n3. Testing Cache Operations".colorize(:blue).bold
begin
  endpoint = "/test"
  query = "city=Austin"
  body = "{\"test\": \"data\"}"
  status = 200
  
  RentcastProxy::CacheManager.cache_with_ttl(endpoint, query, body, status, 3600)
  cached = RentcastProxy::Database.get_cached_response(endpoint, query)
  
  if cached
    puts "✓ Cache operations working correctly".colorize(:green)
  else
    puts "✗ Cache operations failed".colorize(:red)
  end
rescue ex
  puts "✗ Cache test failed: #{ex.message}".colorize(:red)
end

puts "\n4. Testing Error Handling".colorize(:blue).bold
begin
  endpoint = "/error"
  query = "test=404"
  body = "{\"error\": \"Not Found\"}"
  status = 404
  
  RentcastProxy::CacheManager.cache_with_ttl(endpoint, query, body, status, 3600)
  cached = RentcastProxy::Database.get_cached_response(endpoint, query)
  
  if cached.nil?
    puts "✓ Error responses correctly not cached".colorize(:green)
  else
    puts "✗ Error responses incorrectly cached".colorize(:red)
  end
rescue ex
  puts "✗ Error handling test failed: #{ex.message}".colorize(:red)
end

puts "\n✓ All component tests completed!".colorize(:green).bold
puts "\nTo start the proxy server:".colorize(:yellow)
puts "export RENTCAST_API_KEY=\"your_api_key\"".colorize(:cyan)
puts "crystal run src/rentcast-proxy.cr".colorize(:cyan)