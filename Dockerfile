# syntax=docker/dockerfile:1

FROM golang:1.22 AS builder
WORKDIR /app

# Only copy go.mod (you don't have go.sum)
COPY go.mod ./

# download modules
RUN go mod download

# copy rest of source and build
COPY . .
ENV CGO_ENABLED=0 GOOS=linux GOARCH=amd64
RUN go build -ldflags="-s -w" -o /app/main .

FROM gcr.io/distroless/static:nonroot
COPY --from=builder /app/main /app/main
COPY --from=builder /app/static /app/static

WORKDIR /app
EXPOSE 8080
USER nonroot:nonroot
CMD ["/app/main"]
