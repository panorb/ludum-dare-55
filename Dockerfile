FROM ubuntu:jammy

USER root
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get clean && rm -rf /var/lib/apt/lists/* && apt-get update -y
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    git-lfs \
    unzip \
    wget \
    zip \
    adb \
    openjdk-17-jdk-headless \
    rsync \
    && rm -rf /var/lib/apt/lists/*

ARG GODOT_VERSION="4.3"
ARG SUBDIR="dev5"
ARG GODOT_TEST_ARGS=""
ARG GODOT_PLATFORM="linux.x86_64"

RUN wget https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/${SUBDIR}/Godot_v${GODOT_VERSION}-${SUBDIR}_${GODOT_PLATFORM}.zip \
    && wget https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/${SUBDIR}/Godot_v${GODOT_VERSION}-${SUBDIR}_export_templates.tpz \
    && mkdir ~/.cache \
    && mkdir -p ~/.config/godot \
    && mkdir -p ~/.local/share/godot/export_templates/${GODOT_VERSION} \
    && unzip Godot_v${GODOT_VERSION}-${SUBDIR}_${GODOT_PLATFORM}.zip \
    && mv Godot_v${GODOT_VERSION}-${SUBDIR}_${GODOT_PLATFORM} /usr/local/bin/godot \
    && unzip Godot_v${GODOT_VERSION}-${SUBDIR}_export_templates.tpz \
    && mv templates/* ~/.local/share/godot/export_templates/${GODOT_VERSION}-${SUBDIR} \
    && rm -f Godot_v${GODOT_VERSION}-${SUBDIR}_export_templates.tpz Godot_v${GODOT_VERSION}-${SUBDIR}_${GODOT_PLATFORM}.zip
