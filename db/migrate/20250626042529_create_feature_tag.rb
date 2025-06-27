class CreateFeatureTag < ActiveRecord::Migration[8.0]
  def change
    create_table :pin_flags_feature_tags do |t|
      t.string :name, null: false
      t.boolean :enabled, default: true, null: false

      t.timestamps
    end

    add_index :pin_flags_feature_tags, :name, unique: true
  end
end
