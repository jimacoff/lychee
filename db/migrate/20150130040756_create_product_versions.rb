class CreateProductVersions < ActiveRecord::Migration
  def change
    create_table :product_versions do |t|
      t.string   :item_type, :null => false
      t.integer  :item_id,   :null => false
      t.string   :event,     :null => false
      t.string   :whodunnit
      t.text     :object
      t.datetime :created_at
      t.integer  :transaction_id
    end
    add_index :product_versions, [:item_type, :item_id, :transaction_id],
              name: 'index_on_item_type_and_item_id_and_transaction_id'
  end

  def up
    execute <<-SQL
      CREATE SEQUENCE product_version_id_seq;
      ALTER SEQUENCE product_version_id_seq OWNED BY product_versions.item_id;
    SQL

    execute <<-SQL
          ALTER TABLE scores ALTER COLUMN job_id SET DEFAULT nextval('job_id_seq');
        SQL
  end

  def down
    execute <<-SQL
      DROP SEQUENCE product_version_id_seq;
    SQL
  end
end
