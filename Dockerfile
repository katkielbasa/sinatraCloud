FROM ruby:2.3

WORKDIR /usr/src/app

COPY . .

COPY Gemfile Gemfile.lock ./
RUN bundle install
EXPOSE 9292

CMD ["/usr/local/bundle/bin/rackup", "-p", "9292", "-o", "0.0.0.0", "./config.ru"]
