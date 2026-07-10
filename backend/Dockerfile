# Build stage
FROM golang:1.26-alpine AS builder

WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -trimpath \
    -ldflags="-s -w" \
    -o /skillpulse-api .

# Minimal runtime stage
FROM scratch

COPY --from=builder /skillpulse-api /skillpulse-api

USER 65532:65532

EXPOSE 8080

ENTRYPOINT ["/skillpulse-api"]
