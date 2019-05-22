# syntax=docker/dockerfile:1.0-experimental

FROM ubuntu:latest as dev

RUN	true \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		python3.7 \
	&& mkdir -p /usr/local/idea \
	&& curl -L https://download.jetbrains.com/idea/ideaIC-2019.1.2-jbr11.tar.gz | tar -xzC /usr/local/idea
