FROM viryaos/apkrepo-sdk:v3.7-f9139a9-aarch64.x86_64 AS apkrepo-sdk

FROM alpine:3.7 as alpine

COPY --from=apkrepo-sdk /home/builder/apkrepo/sdk/ /tmp/docker-build/apkrepo-sdk/

COPY [ \
  "./docker-extras/*", \
  "/tmp/docker-build/" \
]

RUN \
  # apk
  apk update && \
  \
  apk add alpine-baselayout && \
  apk add alpine-sdk && \
  apk add vim && \
  \
  # setup abuild
  mkdir -p /var/cache/distfiles && \
  adduser -D -u 500 builder && \
  addgroup builder abuild && \
  chgrp abuild /var/cache/distfiles && \
  chmod g+w /var/cache/distfiles && \
  echo "builder    ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
  su -l builder -c "git config --global user.email Builder" && \
  su -l builder -c "git config --global user.name builder@viryaos" && \
  \
  sed -i -e "/^#PACKAGER.*$/d" /etc/abuild.conf && \
  echo 'PACKAGER="Builder <builder@viryaos>"' >> /etc/abuild.conf && \
  \
  # Copy keys to where abuild needs them
  su -l builder -c "mkdir .abuild" && \
  su -l builder -c "cp /tmp/docker-build/home-builder-.abuild-abuild.conf .abuild/abuild.conf" && \
  su -l builder -c "cp /tmp/docker-build/home-builder-.abuild-Builder-59ffc9b9.rsa.pub .abuild/Builder-59ffc9b9.rsa.pub" && \
  cp /home/builder/.abuild/*.rsa.pub /etc/apk/keys && \
  \
  # setup qemu-system-x86_64
  echo "@apkrepo-sdk /tmp/docker-build/apkrepo-sdk/v3.7/main" >> /etc/apk/repositories && \
  apk update && \
  apk add qemu-system-x86_64@apkrepo-sdk && \
  \
  # remove @apkrepo-sdk from apk
  sed -i -e 's/@apkrepo-sdk//' /etc/apk/world && \
  sed -i -e '/@apkrepo-sdk/d' /etc/apk/repositories && \
  \
  # cleanup
  cd /root && \
  rm -rf /tmp/* && \
  rm -f /var/cache/apk/*
