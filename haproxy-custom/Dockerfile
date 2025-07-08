FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y haproxy keepalived iproute2 iputils-ping curl psmisc && \
    rm -rf /var/lib/apt/lists/*

COPY haproxy.cfg /etc/haproxy/haproxy.cfg
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
