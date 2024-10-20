# Build stage
FROM golang:1.23.2-alpine3.19 AS build
WORKDIR /app
COPY ./app .
RUN go build -o main hello-world.go

# Run stage  
FROM alpine:3.19
WORKDIR /app
COPY --from=build /app/main .
CMD ["/app/main"]