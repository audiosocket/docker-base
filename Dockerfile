FROM ubuntu:14.04

MAINTAINER it@audiosocket.com

WORKDIR /tmp/workdir

# apts

RUN apt-get update && apt-get install -y build-essential git mercurial perl curl cmake g++ autoconf libtool openssl pkg-config zlib1g-dev libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt-dev software-properties-common libffi-dev m4 aspcud unzip libx11-dev ocaml ocaml-native-compilers camlp4-extra sudo libfftw3-dev libsamplerate0-dev rsync packup && rm -rf /var/lib/apt/lists/*

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

# ocaml/opam

RUN adduser --disabled-password --gecos "" opam
RUN passwd -l opam
ENV HOME /home/opam
ENV OPAMEXTERNALSOLVER packup
ENV OPAMYES 1

ADD https://raw.githubusercontent.com/ocaml/opam/master/shell/opam_installer.sh /home/opam/opam_installer.sh
RUN sh /home/opam/opam_installer.sh /usr/local/bin 4.01.0

USER opam

WORKDIR /home/opam
RUN git clone git://github.com/alexhemard/opam-repository
RUN opam init --comp=4.01.0 -a -y /home/opam/opam-repository
RUN opam install ocamlfind camlp4
