FROM ruby:2.5.3

WORKDIR /tmp/setup
COPY Gemfile ./
RUN bundle install

WORKDIR /tmp
RUN rm -d -rf /tmp/setup

CMD ruby --version
