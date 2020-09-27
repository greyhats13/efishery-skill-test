FROM golang:1.14.0-alpine3.11 AS builder

RUN apk update && apk add --no-cache git

WORKDIR $GOPATH/src/efishery/

COPY . .

RUN GOOS=linux GOARCH=amd64 go build -o /go/bin/demo

FROM alpine:3.11

RUN apk update && apk add --no-cache tzdata

COPY --from=builder /go/bin/demo /go/bin/demo

ENTRYPOINT ["/go/bin/demo"]