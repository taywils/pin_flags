class CreateFeatureSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :pin_flags_feature_subscriptions do |t|
      t.references :feature_tag, null: false, foreign_key: { to_table: :pin_flags_feature_tags }
      t.references :feature_taggable, polymorphic: true, null: false

      t.timestamps
    end

    add_index :pin_flags_feature_subscriptions, [ :feature_taggable_type, :feature_taggable_id ]
    add_index :pin_flags_feature_subscriptions, [ :feature_tag_id, :feature_taggable_type, :feature_taggable_id ],
              unique: true, name: "index_feature_subscriptions_unique"
  end
end
