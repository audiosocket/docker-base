FROM ubuntu:14.04

WORKDIR /tmp/workdir

RUN useradd -ms /bin/bash iguana -d /home/iguana && \
chown -R iguana /home/iguana

USER root

# apts

RUN apt-get update && apt-get install -y build-essential git mercurial perl curl cmake g++ autoconf libtool openssl pkg-config zlib1g-dev libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt-dev software-properties-common libffi-dev

# ffmpeg

ENV FFMPEG_VERSION  2.7.1
ENV MPLAYER_VERSION 1.1.1
ENV YASM_VERSION    1.3.0
ENV OGG_VERSION     1.3.2
ENV VORBIS_VERSION  1.3.4
ENV LAME_VERSION    3.99.5
ENV FAAC_VERSION    1.28
ENV XVID_VERSION    1.3.3
ENV FDKAAC_VERSION  0.1.3
ENV SRC /usr/local
ENV LD_LIBRARY_PATH ${SRC}/lib
ENV PKG_CONFIG_PATH ${SRC}/lib/pkgconfig

COPY ffmpeg.sh /tmp/ffmpeg.sh

# RUN bash /tmp/ffmpeg.sh

# RUN ffmpeg -buildconf

COPY rubies.txt /tmp/rubies.txt
COPY ruby.sh /tmp/ruby.sh

USER iguana

RUN bash /tmp/ruby.sh
