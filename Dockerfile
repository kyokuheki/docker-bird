FROM buildpack-deps:sid-scm as builder
LABEL maintainer Kenzo Okuda <okuda.kenzo@nttv6.net>

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    autoconf \
    flex \
    bison \
    libncursesw5-dev \
    libreadline6-dev

RUN set -eux \
 && git clone -b v2.0.6 --depth=1 https://gitlab.labs.nic.cz/labs/bird.git \
 && cd bird \
 && autoheader \
 && autoconf \
 && ./configure --prefix=/usr --sysconfdir=/etc --runstatedir=/var/run/bird \
 && make \
 && make install

FROM alpine:latest
LABEL maintainer Kenzo Okuda <kyokuheki@gmail.com>

COPY --from=builder /usr/sbin/bird /usr/sbin/birdcl /usr/sbin/birdc /usr/sbin/
COPY --from=builder /etc/bird.conf /etc/bird/

RUN set -eux \
 && mkdir -p /var/run/bird

RUN apk add --no-cache \
    iproute2 \
    tcpdump \
    curl

VOLUME ["/etc/bird", "/var/run/bird"]
ENTRYPOINT ["/usr/sbin/bird"]
CMD ["-d", "-f", "-c", "/etc/bird/bird.conf", "-s", "/run/bird.ctl"]
