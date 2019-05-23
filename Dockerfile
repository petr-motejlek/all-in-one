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
		autoconf \
		automake \
		gcc \
		libtool \
		make \
	&& find /var/lib/apt/lists \
		-mindepth 1 \
		-delete

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
COPY /src /src
RUN	true \
	&& cd /src \
	&& ./buildconf \
	&& ./configure --disable-shared --prefix=/compiled \
	&& make \
	&& make install


FROM runtime-deps
COPY --from=compiled /compiled/bin/curl /curl

ENTRYPOINT ["/curl"]
