require 'rspec'
require 'stable_redis_pagination'

RSpec.configure do |config|
  config.before(:all) do
    StableRedisPagination.redis = Redis.new(:db => 15)
  end

  config.before(:each) do
    StableRedisPagination.redis.flushdb
  end

  config.after(:all) do
    StableRedisPagination.redis.flushdb
  end
end
