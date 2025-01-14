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

ActiveRecord::Schema[8.0].define(version: 2025_01_14_173305) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "achievement_progresses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "achievement_id", null: false
    t.integer "current_value", default: 0, null: false
    t.integer "target_value", null: false
    t.datetime "last_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["achievement_id"], name: "index_achievement_progresses_on_achievement_id"
    t.index ["user_id", "achievement_id"], name: "index_achievement_progresses_on_user_id_and_achievement_id", unique: true
    t.index ["user_id"], name: "index_achievement_progresses_on_user_id"
  end

  create_table "achievement_shares", force: :cascade do |t|
    t.bigint "user_achievement_id", null: false
    t.text "message"
    t.integer "likes_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_achievement_id"], name: "index_achievement_shares_on_user_achievement_id"
  end

  create_table "achievements", force: :cascade do |t|
    t.string "name", null: false
    t.text "description", null: false
    t.string "badge_icon", null: false
    t.integer "points", default: 0, null: false
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_achievements_on_category"
    t.index ["name"], name: "index_achievements_on_name", unique: true
  end

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "blog_categories", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "blog_post_drafts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "blog_post_id"
    t.string "title"
    t.text "content"
    t.text "summary"
    t.string "tag_list"
    t.integer "blog_series_id"
    t.datetime "last_edited_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blog_post_id"], name: "index_blog_post_drafts_on_blog_post_id"
    t.index ["user_id"], name: "index_blog_post_drafts_on_user_id"
  end

  create_table "blog_post_likes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "blog_post_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blog_post_id"], name: "index_blog_post_likes_on_blog_post_id"
    t.index ["user_id"], name: "index_blog_post_likes_on_user_id"
  end

  create_table "blog_post_tags", force: :cascade do |t|
    t.bigint "blog_post_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blog_post_id", "tag_id"], name: "index_blog_post_tags_on_blog_post_id_and_tag_id", unique: true
    t.index ["blog_post_id"], name: "index_blog_post_tags_on_blog_post_id"
    t.index ["tag_id"], name: "index_blog_post_tags_on_tag_id"
  end

  create_table "blog_posts", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.string "slug"
    t.boolean "published"
    t.datetime "published_at"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "blog_series_id"
    t.integer "position"
    t.index ["blog_series_id", "position"], name: "index_blog_posts_on_blog_series_id_and_position", unique: true, where: "((blog_series_id IS NOT NULL) AND (\"position\" IS NOT NULL))"
    t.index ["blog_series_id"], name: "index_blog_posts_on_blog_series_id"
    t.index ["user_id"], name: "index_blog_posts_on_user_id"
  end

  create_table "blog_series", force: :cascade do |t|
    t.string "title", null: false
    t.string "slug", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_blog_series_on_slug", unique: true
    t.index ["user_id"], name: "index_blog_series_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "content", null: false
    t.bigint "blog_post_id", null: false
    t.bigint "user_id"
    t.bigint "parent_id"
    t.string "author_name"
    t.string "author_email"
    t.boolean "approved", default: false
    t.datetime "approved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "score", default: 0, null: false
    t.integer "upvotes_count", default: 0, null: false
    t.integer "downvotes_count", default: 0, null: false
    t.index ["blog_post_id", "created_at"], name: "index_comments_on_blog_post_id_and_created_at"
    t.index ["blog_post_id"], name: "index_comments_on_blog_post_id"
    t.index ["parent_id"], name: "index_comments_on_parent_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "follows", force: :cascade do |t|
    t.bigint "follower_id", null: false
    t.bigint "followed_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["followed_id"], name: "index_follows_on_followed_id"
    t.index ["follower_id", "followed_id"], name: "index_follows_on_follower_id_and_followed_id", unique: true
    t.index ["follower_id"], name: "index_follows_on_follower_id"
  end

  create_table "gallery_images", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.text "description"
    t.string "alt_text"
    t.integer "width"
    t.integer "height"
    t.string "content_type"
    t.integer "file_size"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_gallery_images_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "recipient_id", null: false
    t.bigint "actor_id"
    t.string "action", null: false
    t.string "notifiable_type", null: false
    t.bigint "notifiable_id", null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_notifications_on_actor_id"
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
    t.index ["recipient_id", "read_at"], name: "index_notifications_on_recipient_id_and_read_at"
    t.index ["recipient_id"], name: "index_notifications_on_recipient_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.string "email", null: false
    t.string "name"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "unsubscribed_at"
    t.string "preferences", default: [], array: true
    t.jsonb "metadata", default: {}
    t.bigint "user_id"
    t.string "subscription_type"
    t.string "status"
    t.datetime "last_sent_at"
    t.integer "send_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_subscriptions_on_confirmation_token", unique: true
    t.index ["email"], name: "index_subscriptions_on_email", unique: true
    t.index ["preferences"], name: "index_subscriptions_on_preferences", using: :gin
    t.index ["status"], name: "index_subscriptions_on_status"
    t.index ["subscription_type"], name: "index_subscriptions_on_subscription_type"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
    t.index ["slug"], name: "index_tags_on_slug", unique: true
  end

  create_table "user_achievements", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "achievement_id", null: false
    t.datetime "unlocked_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["achievement_id"], name: "index_user_achievements_on_achievement_id"
    t.index ["user_id", "achievement_id"], name: "index_user_achievements_on_user_id_and_achievement_id", unique: true
    t.index ["user_id"], name: "index_user_achievements_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name"
    t.date "date_of_birth"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.string "country"
    t.string "email"
    t.integer "role_id", default: 0
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "terms_of_service", default: false, null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "votes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "comment_id", null: false
    t.integer "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["comment_id"], name: "index_votes_on_comment_id"
    t.index ["user_id", "comment_id"], name: "index_votes_on_user_id_and_comment_id", unique: true
    t.index ["user_id"], name: "index_votes_on_user_id"
  end

  add_foreign_key "achievement_progresses", "achievements"
  add_foreign_key "achievement_progresses", "users"
  add_foreign_key "achievement_shares", "user_achievements"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "blog_post_drafts", "blog_posts"
  add_foreign_key "blog_post_drafts", "users"
  add_foreign_key "blog_post_likes", "blog_posts"
  add_foreign_key "blog_post_likes", "users"
  add_foreign_key "blog_post_tags", "blog_posts"
  add_foreign_key "blog_post_tags", "tags"
  add_foreign_key "blog_posts", "blog_series"
  add_foreign_key "blog_posts", "users"
  add_foreign_key "blog_series", "users"
  add_foreign_key "comments", "blog_posts"
  add_foreign_key "comments", "comments", column: "parent_id"
  add_foreign_key "comments", "users"
  add_foreign_key "follows", "users", column: "followed_id"
  add_foreign_key "follows", "users", column: "follower_id"
  add_foreign_key "gallery_images", "users"
  add_foreign_key "notifications", "users", column: "actor_id"
  add_foreign_key "notifications", "users", column: "recipient_id"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "user_achievements", "achievements"
  add_foreign_key "user_achievements", "users"
  add_foreign_key "votes", "comments"
  add_foreign_key "votes", "users"
end
