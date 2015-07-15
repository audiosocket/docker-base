FROM ubuntu:14.04

WORKDIR /tmp/workdir

# apts

RUN apt-get update && apt-get install -y build-essential git mercurial perl curl cmake g++ autoconf libtool openssl pkg-config zlib1g-dev libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt-dev software-properties-common libffi-dev m4 aspcud unzip libx11-dev ocaml ocaml-native-compilers camlp4-extra sudo

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

RUN bash /tmp/ffmpeg.sh

RUN ffmpeg -buildconf

# rbenv/rubies

RUN git clone https://github.com/sstephenson/rbenv.git /usr/local/rbenv
RUN echo '# rbenv setup' > /etc/profile.d/rbenv.sh
RUN echo 'export RBENV_ROOT=/usr/local/rbenv' >> /etc/profile.d/rbenv.sh
RUN echo 'export PATH="$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH"' >> /etc/profile.d/rbenv.sh
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh
RUN chmod +x /etc/profile.d/rbenv.sh

RUN mkdir /usr/local/rbenv/plugins
RUN git clone https://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build

ENV RBENV_ROOT /usr/local/rbenv

ENV PATH $RBENV_ROOT/bin:$RBENV_ROOT/shims:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

ADD ./rubies.txt /root/rubies.txt

RUN xargs -L 1 rbenv install < /root/rubies.txt

RUN echo 'gem: --no-rdoc --no-ri' >> /.gemrc
RUN bash -l -c 'for v in $(cat /root/rubies.txt); do rbenv global $v; gem install bundler; done'

RUN rbenv global 2.2.0

# # ocaml

# ADD opam-installext /usr/bin/opam-installext
# ADD opam.list /etc/apt/sources.list.d/opam.list

# RUN curl -OL http://download.opensuse.org/repositories/home:ocaml/xUbuntu_14.04/Release.key

# RUN apt-key add - < Release.key
# RUN apt-get -y update

# RUN git clone -b 1.2 git://github.com/ocaml/opam
# RUN sh -c "cd opam && make cold && make install"

# RUN adduser --disabled-password --gecos "" opam
# RUN passwd -l opam

# ADD opamsudo /etc/sudoers.d/opam
# RUN chmod 440 /etc/sudoers.d/opam
# RUN chown root:root /etc/sudoers.d/opam
# RUN chown -R opam:opam /home/opam

# USER opam

# ENV HOME /home/opam
# ENV OPAMYES 1

# WORKDIR /home/opam
# USER opam

# RUN sudo -u opam sh -c "git clone git://github.com/ocaml/opam-repository"
# RUN sudo -u opam sh -c "opam init -a -y /home/opam/opam-repository"
# RUN sudo -u opam sh -c "opam switch -y 4.02.1"
# RUN sudo -u opam sh -c "opam install ocamlfind camlp4"

# WORKDIR /home/opam/opam-repository

# ONBUILD RUN sudo -u opam sh -c "cd /home/opam/opam-repository && git pull && opam update -u -y"
