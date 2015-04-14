require 'active_record/connection_adapters/postgresql_adapter'

# Utilise bigserial/bigint as identifiers through the entire application
# This ensures we don't need to have `length: 8` appear in every migration

ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::
  NATIVE_DATABASE_TYPES[:primary_key] = 'bigserial primary key'

# Adapted from
# https://github.com/orenmazor/rails-bigint-pk/blob/master/lib/bigint_pk.rb
[ActiveRecord::ConnectionAdapters::TableDefinition,
 ActiveRecord::ConnectionAdapters::Table].each do |abstract_table_type|
  abstract_table_type.class_eval do
    def references_with_default_bigint_fk(*args)
      options = args.extract_options!
      options.reverse_merge! limit: 8

      if options[:polymorphic] == true
        options[:polymorphic] = options.except(:polymorphic, :limit)
      end

      references_without_default_bigint_fk(*args, options)
    end
    alias_method_chain :references, :default_bigint_fk
  end
end

[ActiveRecord::ConnectionAdapters::SchemaStatements].each do |schema_statement|
  schema_statement.class_eval do
    def add_reference_with_default_bigint_fk(*args)
      options = args.extract_options!
      options.reverse_merge! limit: 8

      if options[:polymorphic] == true
        options[:polymorphic] = options.except(:polymorphic, :limit)
      end

      add_reference_without_default_bigint_fk(*args, options)
    end
    alias_method_chain :add_reference, :default_bigint_fk
  end
end
