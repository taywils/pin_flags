class CreateFeatureTag < ActiveRecord::Migration[8.0]
  def up
    create_table :pin_flags_feature_tags do |t|
      t.string :name, null: false
      t.boolean :enabled, default: true, null: false

      t.timestamps
    end

    add_index :pin_flags_feature_tags, :name, unique: true
  end

  def down
    if table_exists?(:pin_flags_feature_tags)
      remove_index :pin_flags_feature_tags, :name if index_exists?(:pin_flags_feature_tags, :name)
      drop_table :pin_flags_feature_tags
    end
  end
end
