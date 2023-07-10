ARG JEKYLL_VERSION
FROM jekyll/jekyll:${JEKYLL_VERSION}

WORKDIR /srv/jekyll
COPY Gemfile .
RUN bundle install
