FROM debian:12-slim@sha256:804194b909ef23fb995d9412c9378fb3505fe2427b70f3cc425339e48a828fca AS builder
WORKDIR /web

RUN apt-get update && \
    apt-get install --no-install-recommends -y git wget ca-certificates
RUN git clone https://github.com/wiedehopf/tar1090.git tar1090

FROM caddy:2-builder@sha256:fb492c5c699ceb5a0cd99a25034cf910cb9ec22e96da13c62b4beff1c99b248d AS caddybuilder

RUN xcaddy build \
    --with github.com/caddy-dns/duckdns \
    --with github.com/caddy-dns/cloudflare

FROM gcr.io/distroless/static-debian12:latest@sha256:41972110a1c1a5c0b6adb283e8aa092c43c31f7c5d79b8656fbffff2c3e61f05
COPY --from=builder /web/tar1090/html/ /srv
COPY --from=caddybuilder /usr/bin/caddy /usr/bin/caddy

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]