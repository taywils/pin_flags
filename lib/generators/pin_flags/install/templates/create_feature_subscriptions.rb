class CreateFeatureSubscriptions < ActiveRecord::Migration[8.0]
  def up
    create_table :pin_flags_feature_subscriptions do |t|
      t.references :feature_tag, null: false, foreign_key: { to_table: :pin_flags_feature_tags }
      t.references :feature_taggable, polymorphic: true, null: false, index: false

      t.timestamps
    end

    add_index :pin_flags_feature_subscriptions,
              %i[feature_tag_id feature_taggable_type feature_taggable_id],
              unique: true,
              name: "idx_pf_subs_on_tag_and_taggable"
  end

  def down
    if table_exists?(:pin_flags_feature_subscriptions)
      remove_index :pin_flags_feature_subscriptions, name: "idx_pf_subs_on_tag_and_taggable" if index_exists?(:pin_flags_feature_subscriptions, name: "idx_pf_subs_on_tag_and_taggable")
      drop_table :pin_flags_feature_subscriptions
    end
  end
end
