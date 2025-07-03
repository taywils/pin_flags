class CreateFeatureSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :pin_flags_feature_subscriptions do |t|
      t.references :feature_tag, null: false, foreign_key: { to_table: :pin_flags_feature_tags }
      t.string :subscriber_type, null: false
      t.bigint :subscriber_id, null: false

      t.timestamps
    end

    add_index :pin_flags_feature_subscriptions, [ :subscriber_type, :subscriber_id ]
    add_index :pin_flags_feature_subscriptions, [ :feature_tag_id, :subscriber_type, :subscriber_id ],
              unique: true, name: "index_feature_subscriptions_unique"
  end
end
