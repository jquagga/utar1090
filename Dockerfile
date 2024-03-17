FROM debian:12-slim@sha256:ccb33c3ac5b02588fc1d9e4fc09b952e433d0c54d8618d0ee1afadf1f3cf2455 AS builder
WORKDIR /web

RUN apt-get update && \
    apt-get install --no-install-recommends -y git wget ca-certificates
RUN git clone https://github.com/wiedehopf/tar1090.git tar1090

FROM caddy:2-builder@sha256:089bf0323bacd73b89c9e840c01bbb6fff2f45a50d5a66dd2eb9e9b743ed1ba3 AS caddybuilder

RUN xcaddy build \
    --with github.com/caddy-dns/duckdns

FROM caddy:2@sha256:d8d3637a26f50bf0bd27a6151d2bd4f7a9f0455936fe7ca2498abbc2e26c841e
COPY --from=builder /web/tar1090/html/ /srv
COPY --from=caddybuilder /usr/bin/caddy /usr/bin/caddy

#USER 65532
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]