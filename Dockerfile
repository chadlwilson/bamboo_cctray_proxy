FROM ruby:2.6-alpine as builder

RUN apk add --no-cache build-base && \
    gem install bundler && \
    bundle config --global frozen 1

WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle install --without test -j4 --retry 3 && \
    rm -rf /usr/local/bundle/bundler/gems/*/.git /usr/local/bundle/cache/

FROM ruby:2.6-alpine

COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY . /app

WORKDIR /app/ramaze
ENTRYPOINT ["ruby", "-rrubygems", "start.rb"]