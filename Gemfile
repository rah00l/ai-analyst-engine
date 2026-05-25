source "https://rubygems.org"

ruby "3.2.11"

# Environment detection
env = ENV.fetch("RACK_ENV", "development")

puts "=" * 50
puts "Loading Gemfile for: #{env.upcase}"
puts "=" * 50

# Development group: Use Sinatra 3.0
if env == "development"
  puts "✅ Development: Using Sinatra 3.0"
  puts "   → Compatible with local Docker setup"
  puts "   → No Rack::Protection issues"
  gem "sinatra", "~> 3.0"
end

# Production group: Can use newer Sinatra
if env == "production"
  puts "✅ Production: Using Sinatra 4.0"
  puts "   → Latest version"
  puts "   → Works on Railway"
  gem "sinatra", "~> 4.0"
end


# HTTP servers
gem "rackup"
gem "puma"

# JSON handling
gem "json"

# Logging
gem "logger"

# Development tools
group :development do
  gem "rake"
end

# Production specific (optional)
group :production do
  # Add production-specific gems if needed
end