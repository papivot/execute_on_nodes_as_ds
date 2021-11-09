ROM ubuntu:20.04
ENV DEBIAN_FRONTEND=nonintercative

RUN apt-get update -y

ADD https://github.com/krallin/tini/releases/download/v0.19.0/tini /sbin/tini
RUN chmod +x /sbin/tini
COPY exec_on_node.sh /bin
RUN chmod +x /bin/exec_on_node.sh

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/bin/exec_on_node.sh"]
