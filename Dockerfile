FROM crystallang/crystal:1.14.0-alpine AS base

# Install dependencies
RUN apk add --no-cache \
    sqlite-dev \
    sqlite-static \
    yaml-static \
    zlib-static \
    openssl-libs-static \
    openssl-dev \
    musl-dev \
    gcc

WORKDIR /app

# Copy shard files first for better layer caching
COPY shard.yml shard.lock ./

# Install shards (will be cached if shard files don't change)
RUN shards install --production

# Install ameba for linting
RUN shards install ameba

FROM base AS builder

# Copy source code
COPY src/ ./src/
COPY spec/ ./spec/

# Run linting
RUN ./bin/ameba src/

# Run tests
RUN crystal spec

# Build the application
RUN crystal build src/rentcast-proxy.cr \
    --release \
    --static \
    --no-debug \
    --link-flags "-static" \
    -o rentcast-proxy

FROM alpine:3.19 AS runtime

# Install runtime dependencies
RUN apk add --no-cache ca-certificates

# Create non-root user
RUN addgroup -g 1000 rentcast && \
    adduser -D -u 1000 -G rentcast -s /bin/sh rentcast

# Create app directory
WORKDIR /app
RUN chown rentcast:rentcast /app

# Copy binary from builder
COPY --from=builder --chown=rentcast:rentcast /app/rentcast-proxy /app/

# Switch to non-root user
USER rentcast

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# Default command
CMD ["./rentcast-proxy"]