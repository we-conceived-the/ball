FROM debian:stretch
LABEL maintainer="Ball Developers <dev@ball.org>"
LABEL description="Dockerised BallCore, built from Travis"

RUN apt-get update && apt-get -y upgrade && apt-get clean && rm -fr /var/cache/apt/*

COPY bin/* /usr/bin/
