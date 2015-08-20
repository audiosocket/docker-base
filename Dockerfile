FROM gliderlabs/alpine

RUN adduser -D audiobot
ENV HOME /home/audiobot

WORKDIR /home/audiobot

# apk

RUN apk update && apk add patch bash ffmpeg ruby unzip m4 make gcc git musl-dev libsamplerate-dev zlib-dev openssl-dev readline-dev 
RUN apk add ocaml --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted

# Boo

USER audiobot

RUN curl -OL http://www.fftw.org/fftw-3.3.4.tar.gz
RUN tar xvzf fftw-3.3.4.tar.gz
RUN cd fftw-3.3.4 && ./configure --prefix /usr --enable-shared && make

USER root
RUN cd fftw-3.3.4 && make install

# rbenv/rubies

USER audiobot

RUN git clone https://github.com/sstephenson/rbenv.git /home/audiobot/.rbenv

USER root
RUN ln -s /home/audiobot/.rbenv/bin/rbenv /usr/local/bin

USER audiobot

RUN mkdir /home/audiobot/.rbenv/plugins
RUN git clone https://github.com/sstephenson/ruby-build.git /home/audiobot/.rbenv/plugins/ruby-build

ENV RBENV_ROOT /home/audiobot/.rbenv

ADD ./rubies.txt /home/audiobot/rubies.txt

ENV CONFIGURE_OPTS CFLAGS=-fPIC

RUN xargs rbenv install < /home/audiobot/rubies.txt

RUN echo 'gem: --no-rdoc --no-ri' >> /home/audiobot/.gemrc
RUN bash -l -c 'eval "$(rbenv init -)" && for v in $(cat /home/audiobot/rubies.txt); do rbenv local $v && gem install bundler; done'

RUN rbenv local 2.2.0

# Opam

RUN curl -OL https://github.com/ocaml/opam/releases/download/1.2.2/opam-full-1.2.2.tar.gz
RUN tar xvzf opam-full-1.2.2.tar.gz && cd opam-full-1.2.2 && ./configure && make lib-ext all

USER root
RUN cd opam-full-1.2.2 && make install

USER audiobot

ENV OPAMYES 1

RUN opam init --comp=4.03.0+trunk -a -y

RUN opam install atdgen redis cryptokit fftw3 samplerate ounit
