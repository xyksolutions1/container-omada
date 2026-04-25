# SPDX-FileCopyrightText: © 2025 Nfrastack <code@nfrastack.com>
#
# SPDX-License-Identifier: MIT

ARG \
    BASE_IMAGE

FROM docker.io/xyksolutions1/container-base:latest

LABEL \
        org.opencontainers.image.title="Mmada" \
        org.opencontainers.image.description="Containerized Omada Controller" \
        org.opencontainers.image.url="https://hub.docker.com/r/xyksolutions1/omada" \
        org.opencontainers.image.documentation="https://github.com/xyksolutions1/container-omada/blob/main/README.md" \
        org.opencontainers.image.source="https://github.com/xyksolutions1/container-omada.git" \
        org.opencontainers.image.authors="xyksolutions1" \
        org.opencontainers.image.vendor="xyksolutions1" \
        org.opencontainers.image.licenses="MIT"

ARG \
    OMADA_VERSION="6.0.0.25"

COPY CHANGELOG.md /usr/src/container/CHANGELOG.md
COPY LICENSE /usr/src/container/LICENSE
COPY README.md /usr/src/container/README.md

ENV \
    CONTAINER_ENABLE_SCHEDULING=TRUE \
    IMAGE_NAME="xyksolutions1/omada" \
    IMAGE_REPO_URL="https://github.com/xyksolutions1/container-omada/"

RUN echo "" && \
    OMADA_BUILD_DEPS_ALPINE=" \
                            " \
                            && \
    OMADA_RUN_DEPS_ALPINE=" \
                            openjdk21-jre \
                          " \
                          && \
    \
    OMADA_BUILD_DEPS_DEBIAN=" \
                            " \
                            && \
    OMADA_RUN_DEPS_DEBIAN="     \
                          " \
                          && \
    \
    source /container/base/functions/container/build && \
    container_build_log image && \
    create_user omada 1000 omada 1000 /dev/null && \
    package update && \
    package upgrade && \
    package install \
                        OMADA_BUILD_DEPS \
                        OMADA_RUN_DEPS \
                        && \
    \
    mkdir -p /usr/src/omada && \
    curl -ssL https://static.tp-link.com/upload/software/2025/202512/20251203/Omada_SDN_Controller_v6.0.0.25_linux_x64_20251120205736.tar.gz | tar xvfz - --strip 1 -C /usr/src/omada && \
    mkdir -p /app && \
    cp -aR /usr/src/omada/{bin,data,lib} /app/ && \
    mkdir -p \
                /app/properties \
                /container/data/omada/properties \
                && \
    cp -R /usr/src/omada/properties /container/data/omada/ && \
    chown -R omada:omada /app && \
    container_build_log add "Omada" "${OMADA_VERSION}" "${OMADA_REPO_URL}" && \
    package remove \
                    OMADA_BUILD_DEPS \
                    && \
    package cleanup

COPY rootfs /
