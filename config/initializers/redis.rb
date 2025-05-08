# Configure Redis connection
# You can get connection details from environment variables or a configuration file
# Example using default host (localhost) and port (6379)
$redis = Redis.new(host: ENV["REDIS_HOST"] || "localhost", port: ENV["REDIS_PORT"] || 6379)

# Optional: Add a rescue block to handle connection errors during initialization
begin
  $redis.ping
  Rails.logger.info "Redis connected successfully!"
rescue Redis::CannotConnectError => e
  Rails.logger.error "Failed to connect to Redis: #{e.message}"
  # Depending on your application's needs, you might want to exit or handle this differently
end

# Optional: Add a method to reconnect if the connection is lost
# This is a basic example, more robust solutions might involve connection pooling
# or a gem like connection_pool
# def reconnect_redis
#   $redis = Redis.new(host: ENV['REDIS_HOST'] || 'localhost', port: ENV['REDIS_PORT'] || 6379)
#   $redis.ping
# rescue Redis::CannotConnectError => e
#   Rails.logger.error "Failed to reconnect to Redis: #{e.message}"
#   # Handle reconnection failure
# end
