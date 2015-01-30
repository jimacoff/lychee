class CreateProductVersionsSeq < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE SEQUENCE product_version_id_seq;
      ALTER SEQUENCE product_version_id_seq OWNED BY product_versions.item_id;
    SQL

    execute <<-SQL
      ALTER TABLE product_versions ALTER COLUMN item_id SET DEFAULT nextval('product_version_id_seq');
    SQL
  end

  def down
    execute <<-SQL
      DROP SEQUENCE product_version_id_seq;
    SQL
  end
end
