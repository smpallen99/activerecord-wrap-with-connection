require "activerecord-wrap-with-connection/version"

{
  (class << ActiveRecord::Base; self; end) => [
    :find, :first, :last, :all, :destroy, :destroy_all, :exists?, :delete, :delete_all, :update, :update_all, :find_each, :find_in_batches, :select, :group, :order, :reorder, :limit, :joins, :where, :preload, :eager_load, :includes, :from, :lock, :readonly, :having, :create_with, :count, :average, :minimum, :maximum, :sum, :calculate, :find_by_sql, :count_by_sql, :quoted_table_name, :reset_sequence_name, :table_exists?, :columns, :quote_value, :sanitize, :quote_bound_value
  ],
  ActiveRecord::Base => [:create, :quote_value],
  ActiveRecord::Associations::CollectionAssociation => [:initialize, :find, :find_target, :load_target, :count ],
  ActiveRecord::Associations::HasAndBelongsToManyAssociation => [:insert_record, :delete_records],
  ActiveRecord::Associations::HasManyThroughAssociation => [],
  ActiveRecord::Associations::HasOneAssociation => [],
  ActiveRecord::Associations::ClassMethods => [],
  ActiveRecord::Calculations => [:calculate]
}.each do |klass, methods|
  methods.each do |method|
    klass.class_eval do
      alias_method_chain method, :connection do |target, punc|
        eval %{
          def #{target}_with_connection#{punc}(*a, &b)
            ActiveRecord::Base.connection_pool.with_connection do
              #{target}_without_connection#{punc}(*a, &b)
            end
          end
        }
      end
    end
  end
end
