FROM golang:1.21 as builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /bin/avalanche ./cmd/avalanche.go

FROM alpine:latest
RUN apk --no-cache add ca-certificates

COPY --from=builder /bin/avalanche /bin/avalanche

ENTRYPOINT ["/bin/avalanche"]
CMD ["--series-operation-mode=double-halve", "--series-change-interval=30", "--series-count=100"]