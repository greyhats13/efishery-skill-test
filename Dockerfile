FROM golang:1.14.0 AS builder

WORKDIR $GOPATH/src/efishery/

COPY . .

RUN GOOS=linux GOARCH=amd64 go build -o /go/bin/demo

FROM gcr.io/distroless/base

RUN apk update && apk add --no-cache git

COPY --from=builder /go/bin/demo /go/bin/demo

ENTRYPOINT ["/go/bin/demo"]