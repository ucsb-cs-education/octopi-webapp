if Rails.env.production?
  Resque.redis = Redis.new(url: ENV['REDISCLOUD_URL'])
end