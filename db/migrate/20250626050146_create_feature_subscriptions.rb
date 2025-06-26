class CreateFeatureSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :feature_subscriptions do |t|
      t.references :feature_tag, null: false, foreign_key: true
      t.references :feature_taggable, polymorphic: true, null: false

      t.timestamps
    end

    add_index :feature_subscriptions,
              %i[feature_tag_id feature_taggable_type feature_taggable_id],
              unique: true,
              name: 'index_feature_subscriptions_on_tag_and_feature_taggable'
  end
end
