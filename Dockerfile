FROM debian:12-slim@sha256:ccb33c3ac5b02588fc1d9e4fc09b952e433d0c54d8618d0ee1afadf1f3cf2455 AS builder
WORKDIR /web

RUN apt-get update && \
    apt-get install --no-install-recommends -y git wget ca-certificates
RUN git clone https://github.com/wiedehopf/tar1090.git tar1090

FROM nginx:stable@sha256:25b1dd75ab9caf2f84bc35cc82c0924c93a2b5b2495e280bb8f3bad826d5fb37
COPY --from=builder /web/tar1090/html/ /usr/share/nginx/html

USER 65532
CMD ["nginx", "-g", "daemon off;"]