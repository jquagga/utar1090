FROM debian:12-slim@sha256:ccb33c3ac5b02588fc1d9e4fc09b952e433d0c54d8618d0ee1afadf1f3cf2455 AS htmlfiles
WORKDIR /web
RUN apt-get update && \
    apt-get install --no-install-recommends -y git wget ca-certificates
RUN git clone https://github.com/wiedehopf/tar1090.git tar1090

FROM caddy:2-builder@sha256:75f5dafdf92bbf2c4217c169e4d2349c407df5a52df8cadcedd6e722d1bbe36e AS builder
RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/caddy-dns/duckdns

FROM caddy:2@sha256:9fc94ed79892ca33b50bf9e548d6d639e6c8957b9e7b3965086dd754836903b6
COPY --from=htmlfiles /web/tar1090/html/ /srv
COPY --from=builder /usr/bin/caddy /usr/bin/caddy

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]