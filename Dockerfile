FROM debian:12-slim@sha256:ad86386827b083b3d71139050b47ffb32bbd9559ea9b1345a739b14fec2d9ecf AS builder
WORKDIR /web

RUN apt-get update && \
    apt-get install --no-install-recommends -y git wget ca-certificates
RUN git clone https://github.com/wiedehopf/tar1090.git tar1090

FROM caddy:2-builder@sha256:9bbe944a171a6d4b0003c78ce7f28654d6886e292f7575e2be582668e11dc415 AS caddybuilder

RUN xcaddy build \
    --with github.com/caddy-dns/duckdns \
    --with github.com/caddy-dns/cloudflare

FROM gcr.io/distroless/static-debian12:latest@sha256:69830f29ed7545c762777507426a412f97dad3d8d32bae3e74ad3fb6160917ea
COPY --from=builder /web/tar1090/html/ /srv
COPY --from=caddybuilder /usr/bin/caddy /usr/bin/caddy

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]