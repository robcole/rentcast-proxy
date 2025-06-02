# Rentcast API Proxy

A typed API wrapper and proxy for the Rentcast API built in Crystal with caching and SQLite persistence.

## Features

- **Typed API Wrapper**: Fully typed Crystal models for all Rentcast API responses
- **Caching**: SQLite-based caching with configurable TTL (default: 7 days)
- **Proxy Server**: Kemal-based proxy that mirrors Rentcast API structure
- **Error Handling**: Intelligent caching that skips 404s and other errors
- **Auto-cleanup**: Background process to remove expired cache entries

## Installation

1. Install dependencies:
```bash
shards install
```

2. Set your Rentcast API key:
```bash
export RENTCAST_API_KEY="your_api_key_here"
```

3. Build the application:
```bash
crystal build src/rentcast-proxy.cr --release
```

## Usage

### Running the Proxy Server

```bash
./rentcast-proxy
```

The server will start on `http://localhost:3000` and automatically:
- Initialize the SQLite database for caching
- Start the cache cleanup scheduler
- Mirror the Rentcast API endpoints

### Available Endpoints

All endpoints mirror the Rentcast API structure:

- `GET /v1/properties` - Search property records
- `GET /v1/properties/:id` - Get property by ID
- `GET /v1/avm/rent/long-term` - Get rent estimates
- `GET /v1/avm/value` - Get value estimates
- `GET /health` - Health check endpoint

### Cache Headers

The proxy adds cache status headers to responses:
- `X-Cache: HIT` - Response served from cache
- `X-Cache: MISS` - Response fetched from Rentcast API

### Example Usage

```bash
# Search properties in a city
curl "http://localhost:3000/v1/properties?city=Austin&state=TX&limit=10"

# Get property by ID
curl "http://localhost:3000/v1/properties/12345"

# Get rent estimate
curl "http://localhost:3000/v1/avm/rent/long-term?address=123 Main St&city=Austin&state=TX"
```

## Configuration

- **Cache TTL**: Default 7 days (604800 seconds)
- **Database**: SQLite database stored as `cache.db`
- **Port**: 3000 (configurable in code)
- **Cleanup**: Runs every hour to remove expired cache entries

## Development

Format code before committing:
```bash
crystal tool format src/ spec/
```

Run tests:
```bash
crystal spec
```