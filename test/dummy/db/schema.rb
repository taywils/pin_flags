# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_06_26_050146) do
  create_table "pin_flags_feature_subscriptions", force: :cascade do |t|
    t.integer "feature_tag_id", null: false
    t.string "feature_taggable_type", null: false
    t.integer "feature_taggable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "feature_tag_id", "feature_taggable_type", "feature_taggable_id" ], name: "idx_pf_subs_on_tag_and_taggable", unique: true
    t.index [ "feature_tag_id" ], name: "index_pin_flags_feature_subscriptions_on_feature_tag_id"
    t.index [ "feature_taggable_type", "feature_taggable_id" ], name: "index_pin_flags_feature_subscriptions_on_feature_taggable"
  end

  create_table "pin_flags_feature_tags", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "enabled", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "name" ], name: "index_pin_flags_feature_tags_on_name", unique: true
  end

  add_foreign_key "pin_flags_feature_subscriptions", "pin_flags_feature_tags", column: "feature_tag_id"
end
