FROM debian:12-slim@sha256:3d5df92588469a4c503adbead0e4129ef3f88e223954011c2169073897547cac AS builder
WORKDIR /web

RUN apt-get update && \
    apt-get install --no-install-recommends -y git wget ca-certificates
RUN git clone https://github.com/wiedehopf/tar1090.git tar1090

FROM caddy:2-builder@sha256:d8a2ad006009b25b7017ab7190128cdd3a0fccee518f5b14fe6c749c6a6293b8 AS caddybuilder

RUN xcaddy build \
    --with github.com/caddy-dns/duckdns \
    --with github.com/caddy-dns/cloudflare

FROM gcr.io/distroless/static-debian12:latest@sha256:41972110a1c1a5c0b6adb283e8aa092c43c31f7c5d79b8656fbffff2c3e61f05
COPY --from=builder /web/tar1090/html/ /srv
COPY --from=caddybuilder /usr/bin/caddy /usr/bin/caddy

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]