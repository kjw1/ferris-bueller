FROM sczizzo/trusty-tool:latest
MAINTAINER Sean Clemmer <sczizzo@gmail.com>
ENV DEBIAN_FRONTEND=noninteractive
ARG BUILD_NUMBER=1

COPY . /build

RUN cd /build \
 && bundle update \
 && bundle exec rake wipe \
 && bundle exec rake package:linux \
 && mkdir /artifacts \
 && mv pkg/*.deb /artifacts

VOLUME /artifacts