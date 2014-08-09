module StableRedisPagination
  class Paginator

    attr_reader :index

    def initialize(index)
      @index = index
    end

    def paginate(**opts)
      range(**opts)
    end

    def can_paginate?
      StableRedisPagination.redis.exists(index)
    end

    def total_index_count
      StableRedisPagination.redis.zcard(index)
    end

    private

    def range(order: 'asc', count: 20, after_id: nil)
      Orderer.new(index, order, after_id, count).ordered_ids
    end

    class Orderer < Struct.new(:index, :order, :after_id, :count)

      def ordered_ids
        StableRedisPagination.redis.send("#{redis_command_prefix}range", index, start, start + count - 1).map(&:to_i)
      end

      private

      def start
        if after_id.nil?
          0
        else
          rank = StableRedisPagination.redis.send("#{redis_command_prefix}rank", index, after_id)
          rank.nil? ? 0 : rank + 1
        end
      end

      def redis_command_prefix
        redis_command_prefix = order.to_s.downcase != 'desc' ? 'z' : 'zrev'
      end
    end
  end
end
