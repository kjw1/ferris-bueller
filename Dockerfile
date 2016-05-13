FROM phusion/baseimage:0.9.18
MAINTAINER Sean Clemmer <sczizzo@gmail.com>
ENV DEBIAN_FRONTEND=noninteractive
COPY pkg/*.deb /tmp/
RUN dpkg -i /tmp/*.deb && rm -rf /tmp/*
ENTRYPOINT [ "ferris-bueller" ]