FROM alpine
LABEL maintainer="seweryn.sitarski@p.lodz.pl"

# Instalacja MooseFs mount
RUN (apk add --no-cache --virtual build-dependencies build-base perl git automake autoconf fuse-dev) \
  && (ln -s /usr/bin/aclocal-1.16 /usr/bin/aclocal-1.15; ln -s /usr/bin/automake-1.16 /usr/bin/automake-1.15) \
  && (git clone -b "v3.0.101" https://github.com/moosefs/moosefs.git) \
  && (apk add fuse)

WORKDIR moosefs
RUN (./configure --disable-mfsmaster --disable-mfsmetalogger --disable-mfssupervisor \
      --disable-mfschunkserver --disable-mfscgi --disable-mfscli --disable-mfscgiserv --disable-mfsnetdump) \
  && (make -j2) \
  && (make install)

WORKDIR /
RUN (rm -rf /moosefs) \
  && (rm /usr/bin/aclocal-1.15; rm /usr/bin/automake-1.15) \
  && (apk del --virtual build-dependencies build-base perl git automake autoconf fuse-dev)



# Instalacja modulu httpd do busybox
RUN apk add busybox-extras

# Konfiguracja DNS
ADD resolv.conf /etc/

CMD ["/bin/sh","-c","/bin/busybox-extras httpd -p 80 -h /srv/ -f -vvv"]
