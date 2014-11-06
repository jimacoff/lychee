require 'active_record/connection_adapters/postgresql_adapter'
module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter < AbstractAdapter
      def drop_database(name)
        fail 'Refusing to drop the production database' if Rails.env.production?
        execute <<-SQL
          UPDATE pg_catalog.pg_database
          SET datallowconn=false WHERE datname='#{name}'
        SQL

        terminate_backend name
        execute "DROP DATABASE IF EXISTS #{quote_table_name(name)}"
      end

      def terminate_backend(name)
        execute <<-SQL
          SELECT pg_terminate_backend(pg_stat_activity.pid)
          FROM pg_stat_activity
          WHERE pg_stat_activity.datname = '#{name}';
        SQL
      end
    end
  end
end
