FROM golang:1.15.2-alpine3.12 AS builder

RUN apk add git

WORKDIR $GOPATH/src/efishery/

COPY . .

RUN GOOS=linux GOARCH=amd64 go build -o /go/bin/demo

FROM alpine:3.12

RUN apk add tzdata

COPY --from=builder /go/bin/demo /go/bin/demo

ENTRYPOINT ["/go/bin/demo"]s