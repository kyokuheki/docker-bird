FROM buildpack-deps:sid-scm as builder
LABEL maintainer Kenzo Okuda <okuda.kenzo@nttv6.net>
ENV DEBIAN_FRONTEND=noninteractive

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
 && ./configure --prefix=/usr --sysconfdir=/etc/bird --runstatedir=/var/run/bird \
 && make \
 && make install

FROM ubuntu:rolling
LABEL maintainer Kenzo Okuda <kyokuheki@gmail.com>
ENV DEBIAN_FRONTEND=noninteractive

COPY --from=builder /usr/sbin/bird /usr/sbin/birdcl /usr/sbin/birdc /usr/sbin/
COPY --from=builder /etc/bird/bird.conf /etc/bird/

RUN set -eux \
 && mkdir -p /var/run/bird

RUN apt-get update && apt-get install -y --no-install-recommends \
    iproute2 \
    tcpdump \
    curl \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

VOLUME ["/etc/bird", "/var/run/bird"]
ENTRYPOINT ["/usr/sbin/bird"]

CMD ["-d", "-f", "-c", "/etc/bird/bird.conf", "-s", "/run/bird.ctl"]
