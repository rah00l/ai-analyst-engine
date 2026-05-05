FROM ruby:3.2-slim

WORKDIR /app

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy app
COPY . .

# Environment
ENV RACK_ENV=development
ENV PORT=4567

EXPOSE 4567

# Run Sinatra via Rack
CMD ["bundle", "exec", "rackup", "sinatra/config.ru", "-o", "0.0.0.0", "-p", "4567"]