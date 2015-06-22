FROM ubuntu:14.04

WORKDIR /tmp/workdir

# apts

RUN apt-get update && apt-get install -y build-essential git mercurial perl curl cmake g++ autoconf libtool openssl pkg-config zlib1g-dev libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt-dev

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

RUN git clone https://github.com/sstephenson/rbenv.git /root/.rbenv
RUN git clone https://github.com/sstephenson/ruby-build.git /root/.rbenv/plugins/ruby-build
RUN /root/.rbenv/plugins/ruby-build/install.sh
ENV PATH /root/.rbenv/bin:$PATH
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh # or /etc/profile
RUN echo 'eval "$(rbenv init -)"' >> .bashrc

ENV CONFIGURE_OPTS --disable-install-doc
ADD ./rubies.txt /root/rubies.txt
RUN xargs -L 1 rbenv install < /root/rubies.txt

RUN echo 'gem: --no-rdoc --no-ri' >> /.gemrc
RUN bash -l -c 'for v in $(cat /root/rubies.txt); do rbenv global $v; gem install bundler; done'
