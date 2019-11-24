FROM ruby:2.6.5
RUN gem install bundler && bundle config --global frozen 1

WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle install --without=test

COPY . .

WORKDIR /app/ramaze
ENTRYPOINT ["ruby", "-rrubygems", "start.rb"]