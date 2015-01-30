class CreateCategoryVersionsSeq < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE SEQUENCE category_version_id_seq;
      ALTER SEQUENCE category_version_id_seq OWNED BY category_versions.item_id;
      ALTER TABLE category_versions ALTER COLUMN item_id SET DEFAULT nextval('category_version_id_seq');
    SQL
  end

  def down
    execute <<-SQL
      DROP SEQUENCE category_version_id_seq;
    SQL
  end
end
