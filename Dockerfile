FROM ruby:3.2-bookworm

WORKDIR /app

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential \
      curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3

# Copy app
COPY . .

# Health check for Railway
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:4567/health || exit 1

EXPOSE 4567

ENV RACK_ENV=production
ENV PORT=4567

CMD ["bundle", "exec", "rackup", "-o", "0.0.0.0", "-p", "4567", "sinatra/config.ru"]