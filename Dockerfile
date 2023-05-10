# Create the smallest and secured golang docker image based on scratch
# https://chemidy.medium.com/create-the-smallest-and-secured-golang-docker-image-based-on-scratch-4752223b7324
# Build with:
# docker build -t web-service-gin .

############################
# STEP 1 build executable binary
############################
# Always pull images by digest.
# golang:alpine-1.20
FROM golang@sha256:4ee203ff3933e7a6f18d3574fd6661a73b58c60f028d2927274400f4774aaa41 AS builder

# Install git + SSL ca certificates.
# Git is required for fetching the dependencies.
# Ca-certificates is required to call HTTPS endpoints.
RUN apk update && apk add --no-cache git ca-certificates tzdata && update-ca-certificates

# Create and use unprivileged user.
ENV USER=appuser
ENV UID=10001 
# See https://stackoverflow.com/a/55757473/12429735RUN 
RUN adduser \    
    --disabled-password \    
    --gecos "" \    
    --home "/nonexistent" \    
    --shell "/sbin/nologin" \    
    --no-create-home \    
    --uid "${UID}" \    
    "${USER}"

WORKDIR $GOPATH/src/mypackage/myapp/
COPY . .

# Fetch dependencies.

# Using go get with go <1.11.
# RUN go get -d -v

# Using go mod with go >=1.11.
RUN go mod download
RUN go mod verify

# Build the binary.
# Remove debug information, compile only for linux target and disable cross compilation.

# With go <1.10.
# RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -installsuffix cgo -ldflags="-w -s" -o /go/bin/main

# With go >=1.10.
RUN GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o /go/bin/main

############################
# STEP 2 build a small image
############################
FROM scratch

# Import zoneinfo for timezones from the builder.
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo

# Import SSL CA certificates from the builder.
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Import the user and group files from the builder.
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

# Copy our static executable.
COPY --from=builder /go/bin/main /go/bin/main

# Use an unprivileged user.
USER appuser:appuser

ENV PORT 8080
ENV GIN_MODE release
EXPOSE 8080

# Run the binary.
ENTRYPOINT ["/go/bin/main"]
