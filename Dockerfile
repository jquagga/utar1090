FROM debian:12-slim@sha256:ccb33c3ac5b02588fc1d9e4fc09b952e433d0c54d8618d0ee1afadf1f3cf2455 AS builder
WORKDIR /web

RUN apt-get update && \
    apt-get install --no-install-recommends -y git wget ca-certificates
RUN git clone https://github.com/wiedehopf/tar1090.git tar1090

FROM caddy:2@sha256:d8d3637a26f50bf0bd27a6151d2bd4f7a9f0455936fe7ca2498abbc2e26c841e
COPY --from=builder /web/tar1090/html/ /srv

#USER 65532
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]