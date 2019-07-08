# syntax=docker/dockerfile:1.0-experimental

FROM ubuntu:latest as runtime-deps
SHELL ["/usr/bin/env", "bash", "-xeuo", "pipefail", "-c"]
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN	true \
    && chmod +x /tini \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		ca-certificates \
	&& find /var/lib/apt/lists \
		-mindepth 1 \
		-delete
ENTRYPOINT ["/tini", "--"]


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


FROM compile-deps as dev
RUN	true \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		git \
		tmux \
		vim \
	&& find /var/lib/apt/lists \
		-mindepth 1 \
		-delete
VOLUME "/work"
CMD ["tmux", "-uCC"]
WORKDIR "/work"


FROM compile-deps as compiled
COPY /src /work/src
RUN	true \
	&& pushd /work/src \
	&& make \
	&& popd


FROM runtime-deps
COPY --from=compiled /opt/nginx /opt/nginx
COPY --from=compiled /run/config /run/config
COPY --from=compiled /run/secret /run/secret
CMD ["/opt/nginx/sbin/nginx"]
EXPOSE 443
