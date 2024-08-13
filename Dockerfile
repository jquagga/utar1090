FROM debian:12-slim@sha256:2ccc7e39b0a6f504d252f807da1fc4b5bcd838e83e4dec3e2f57b2a4a64e7214 AS builder
WORKDIR /web

RUN apt-get update && \
    apt-get install --no-install-recommends -y git wget ca-certificates
RUN git clone https://github.com/wiedehopf/tar1090.git tar1090

FROM caddy:2-builder@sha256:202faaa291d9da41346fbb03609827e9e8004e7c74b3c1bbb5c1248575958da1 AS caddybuilder

RUN xcaddy build \
    --with github.com/caddy-dns/duckdns \
    --with github.com/caddy-dns/cloudflare

FROM gcr.io/distroless/static-debian12:latest@sha256:ce46866b3a5170db3b49364900fb3168dc0833dfb46c26da5c77f22abb01d8c3
COPY --from=builder /web/tar1090/html/ /srv
COPY --from=caddybuilder /usr/bin/caddy /usr/bin/caddy

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]