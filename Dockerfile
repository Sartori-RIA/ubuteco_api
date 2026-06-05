# syntax=docker/dockerfile:1

FROM ruby:4.0.1-slim

WORKDIR /rails

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      curl \
      git \
      imagemagick \
      libpq-dev \
      libvips \
      libyaml-dev \
      postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ARG RAILS_ENV=production
ARG BUNDLE_WITHOUT=development:test

ENV BUNDLE_PATH=/usr/local/bundle \
    RAILS_ENV=${RAILS_ENV} \
    BUNDLE_WITHOUT=${BUNDLE_WITHOUT} \
    BUNDLE_DEPLOYMENT=1

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

RUN chmod +x bin/docker-entrypoint

EXPOSE 3000 50051

ENTRYPOINT ["bin/docker-entrypoint"]
CMD ["bin/rails", "server", "-b", "0.0.0.0"]
