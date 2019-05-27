.PHONY: all build clean install
SHELL := /bin/bash

all: build install

build:
	pushd nginx \
		&& ./auto/configure \
			--prefix=/opt/nginx \
			--conf-path=/run/config/nginx.conf \
			--error-log-path=/dev/stderr \
			--with-http_ssl_module \
		&& make \
	&& popd

clean:
	pushd nginx \
		&& make clean \
	&& popd

install:
	pushd nginx \
		&& make install \
	&& popd \
	&& mkdir -p /run/config \
	&& cp nginx.conf /run/config/ \
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
