FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && apt-get autoremove -y && apt-get purge -y --auto-remove && rm -rf /var/lib/apt/lists/*

ADD https://github.com/krallin/tini/releases/download/v0.19.0/tini /sbin/tini
RUN chmod +x /sbin/tini
COPY exec_on_node.sh /bin
RUN chmod +x /bin/exec_on_node.sh

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/bin/exec_on_node.sh"]
