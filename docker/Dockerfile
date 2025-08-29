# ---- Stage 1: build a tiny Ubuntu rootfs with exactly what we need
ARG UBUNTU_RELEASE=ubuntu-24.04
ARG CHISEL_VERSION=v1.2.0
ARG TARGETARCH=amd64

# Use a public docker cache if issues with downloading from Dockerhub (e.g. rate limiting)
FROM public.ecr.aws/docker/library/ubuntu:24.04 AS chisel
ARG UBUNTU_RELEASE CHISEL_VERSION TARGETARCH

# Fetch chisel binary (no need to keep apt in the final image)
ADD https://github.com/canonical/chisel/releases/download/${CHISEL_VERSION}/chisel_${CHISEL_VERSION}_linux_${TARGETARCH}.tar.gz /tmp/chisel.tgz
RUN tar -xzf /tmp/chisel.tgz -C /usr/local/bin

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl && \
    update-ca-certificates && rm -rf /var/lib/apt/lists/*

# Create rootfs and install only the required package *slices*
# - base-files_* + libc6_libs give you a minimal Ubuntu runtime
# - ca-certificates_data + openssl_config for TLS
# - bash_bins because CMD runs a shell script;
RUN mkdir -p /rootfs && \
    chisel cut --release ${UBUNTU_RELEASE} --root /rootfs \
      base-files_base base-files_release-info \
      libc6_libs ca-certificates_data  openssl_config \
      bash_bins util-linux_bins coreutils_bins

# Install Tini *into the rootfs* (use static if available for your arch)
ADD https://github.com/krallin/tini/releases/download/v0.19.0/tini-${TARGETARCH} /rootfs/sbin/tini
RUN chmod +x /rootfs/sbin/tini

# App payload (your script). Make sure it has the right shebang: #!/usr/bin/env bash
COPY exec_on_node.sh /rootfs/bin/exec_on_node.sh
RUN chmod +x /rootfs/bin/exec_on_node.sh

# ---- Stage 2: final image (distroless-style)
FROM scratch
COPY --from=chisel /rootfs /

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/bin/exec_on_node.sh"]