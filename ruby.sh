git clone https://github.com/sstephenson/rbenv.git $HOME/.rbenv

git clone https://github.com/sstephenson/ruby-build.git $HOME/.rbenv/plugins/ruby-build

export PATH="$HOME/.rbenv/bin:$PATH"

eval "$(rbenv init -)"

echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> $HOME/.bashrc

echo 'eval "$(rbenv init -)"' >> $HOME/.bashrc

export CONFIGURE_OPTS="--disable-install-doc"

xargs -L 1 rbenv install < /tmp/rubies.txt

echo 'gem: --no-rdoc --no-ri' >> $HOME/.gemrc

bash -l -c 'for v in $(cat /tmp/rubies.txt); do rbenv global $v; gem install bundler; done'
