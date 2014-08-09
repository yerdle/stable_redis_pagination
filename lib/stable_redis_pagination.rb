module StableRedisPagination
  class << self
    attr_accessor :redis
  end
end

require 'redis'
require 'stable_redis_pagination/paginator'
require 'stable_redis_pagination/version'
