class RedisIndexBuilder < Struct.new(:config)
  def self.new_from_yml(yml = 'config/redis_indexes.yml')
    new(YAML.load(File.read(Rails.root.join(yml))))
  end

  def self.build_from_yml(yml = 'config/redis_indexes.yml')
    new_from_yml.build
  end

  def self.update_indexes_for_obj(obj)
    new_from_yml.update_indexes_for_obj(obj)
  end

  def self.remove_obj_from_indexes(obj)
    new_from_yml.remove_obj_from_indexes(obj)
  end

  def update_indexes_for_obj(obj)
    config[obj.class.to_s].each do |index_name, opts|
      opts.symbolize_keys!
      if obj_matches_filter_and_tag?(obj, filter: opts[:filter], tag: opts[:tag])
        StableRedisPagination.redis.zadd(index_name, obj.send(opts[:sort_by]).to_f, obj.id) 
      else
        StableRedisPagination.redis.zrem(index_name, obj.id)
      end
    end
  end

  def remove_obj_from_indexes(obj)
    config[obj.class.to_s].keys.each do |index_name|
      StableRedisPagination.redis.zrem(index_name, obj.id)
    end
  end

  def build 
    config.each do |class_name, indexes|
      indexes.each do |index_name, opts|
        remove_index(index_name)
        setup_index(index_name, class_name: class_name, **opts.symbolize_keys)
      end
    end
  end

  def remove_index(index_name)
    StableRedisPagination.redis.zremrangebyrank(index_name, 0, -1)
  end

  def setup_index(index_name, class_name:, sort_by:, order: nil, filter: nil, tag: nil)
    class_name = class_name.constantize unless class_name.is_a?(Class)
    key_prefix = class_name.to_s.underscore
    class_name.find_each do |m|
      if obj_matches_filter_and_tag?(m, filter: filter, tag: tag)
        StableRedisPagination.redis.zadd(index_name, m.send(sort_by).to_f, m.id) 
      end
    end
  end

  def obj_matches_filter_and_tag?(obj, filter: nil, tag: nil)
    (filter.nil? || obj.public_send(filter)) && (tag.nil? || obj.tags.include?(tag))
  end

  module ModelCallbacks
    extend ActiveSupport::Concern
    included do
      after_save {|a| RedisIndexBuilder.update_indexes_for_obj(a) }
      after_destroy {|a| RedisIndexBuilder.remove_obj_from_indexes(a) }
    end
  end
end
