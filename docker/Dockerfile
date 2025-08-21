FROM alpine:3.18

# Add tini, necessary packages and scripts. nsenter is part of util-linux.
ADD https://github.com/krallin/tini/releases/download/v0.19.0/tini /sbin/tini
COPY exec_on_node.sh /bin/
RUN apk update && apk add --no-cache util-linux bash && \
    chmod +x /sbin/tini && \
    chmod +x /bin/exec_on_node.sh

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/bin/exec_on_node.sh"]

# Healthcheck to ensure the container is running
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD exit 0
