# syntax=docker/dockerfile:1.0-experimental

FROM ubuntu:latest as runtime-deps
RUN	true \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		ca-certificates \
	&& find /var/lib/apt/lists \
		-mindepth 1 \
		-delete


FROM runtime-deps as compile-deps
RUN	true \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		build-essential \
		libssl-dev \
		pcre++-dev \
		zlib1g-dev \
	&& find /var/lib/apt/lists \
		-mindepth 1 \
		-delete

# TODO Install tmux and start a bash session as well as vim
FROM compile-deps as dev
RUN	true \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		vim.tiny \
	&& find /var/lib/apt/lists \
		-mindepth 1 \
		-delete

ENTRYPOINT ["/usr/bin/env", "bash"]


FROM compile-deps as compiled
# The default configuration file should be part of /src,
# but I don't wish to fork nginx just because of that :)
COPY nginx.conf /run/config/nginx.conf
COPY /src /src
# TODO Convert this into a Makefile script to be runnable
# using "dev" target
RUN	true \
	&& cd /src \
	&& ./auto/configure \
		--prefix=/opt/nginx \
		--conf-path=/run/config/nginx.conf \
		--error-log-path=/dev/stderr \
		--with-http_ssl_module \
	&& make \
	&& make install \
	&& mkdir -p /run/secret \
	&& openssl req \
		-new \
		-newkey rsa:4096 \
		-days 365 \
		-nodes \
		-x509 \
		-subj "/CN=localhost" \
		-keyout /run/secret/server.key.pem \
		-out /run/secret/server.crt.pem


FROM runtime-deps
COPY --from=compiled /opt/nginx /opt/nginx
COPY --from=compiled /run/config /run/config
COPY --from=compiled /run/secret /run/secret

ENTRYPOINT ["/opt/nginx/sbin/nginx"]
