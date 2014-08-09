module CustomOrderingById
  extend ActiveSupport::Concern

  module ClassMethods
    def order_by_id_list(ids)
      return all if ids.blank?
      values = ids.map {|id| "(#{id}, #{ids.index(id)})" }.join(', ')
      all.
        joins("JOIN (VALUES #{values}) AS ordered(id, ordering) ON #{table_name}.id = ordered.id").
        reorder("ordered.ordering")
    end
  end
end

ActiveRecord::Base.send(:include, CustomOrderingById)
