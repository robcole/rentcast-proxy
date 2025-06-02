ARG BASE_COMPILER_TAG=base-compiler-latest
ARG TARGETPLATFORM

# Try to use the yolo.cr base compiler, fall back to Crystal official if not available
FROM --platform=$TARGETPLATFORM crystallang/crystal:1.16.3-alpine AS base_crystal

# Install dependencies for Crystal builds
RUN apk add --no-cache \
    sqlite-dev \
    sqlite-static \
    yaml-static \
    zlib-static \
    openssl-libs-static \
    openssl-dev \
    musl-dev \
    gcc

# Set up workspace
WORKDIR /app

FROM base_crystal AS compiler

FROM compiler AS builder

WORKDIR /app

# Copy shard files for dependency management
COPY shard.yml shard.lock ./

# Install all dependencies including development ones for ameba
RUN shards install

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

FROM --platform=$TARGETPLATFORM debian:bookworm-slim AS runtime

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y ca-certificates curl libyaml-0-2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -g 1000 rentcast && \
    useradd -r -u 1000 -g rentcast -s /bin/sh rentcast

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
  CMD curl -f http://localhost:3000/health || exit 1

# Default command
CMD ["./rentcast-proxy"] 