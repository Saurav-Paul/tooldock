# Build stage
FROM golang:1.21-alpine AS builder

# Install build dependencies
RUN apk add --no-cache git make bash

# Set working directory
WORKDIR /app/tooldock

# Copy go mod files
COPY tooldock/go.mod tooldock/go.sum* ./

# Download dependencies
RUN go mod download

# Copy source code
COPY tooldock/ ./

# Build the binary
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o /app/build/tooldock .

# Development stage (for interactive development)
FROM golang:1.21-alpine AS dev

RUN apk add --no-cache git make bash

WORKDIR /app

# Copy go mod files
COPY tooldock/go.mod tooldock/go.sum* tooldock/
RUN cd tooldock && go mod download

# Source code will be mounted as volume
CMD ["/bin/bash"]

# Runtime stage (minimal image with just the binary)
FROM alpine:latest AS runtime

RUN apk add --no-cache ca-certificates bash

COPY --from=builder /app/build/tooldock /usr/local/bin/tooldock

ENTRYPOINT ["tooldock"]
