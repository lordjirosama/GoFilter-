# ---------- Build stage ----------
FROM golang:1.22-bullseye AS builder

WORKDIR /app

# Copy go mod files first (better caching)
COPY go.mod go.sum ./
RUN go mod download

# Copy source
COPY . .

# Build static binary
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o bot

# ---------- Runtime stage ----------
FROM debian:bullseye-slim

WORKDIR /app

COPY --from=builder /app/bot .

# (Optional) CA certs for HTTPS / Telegram API
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

CMD ["./bot"]
