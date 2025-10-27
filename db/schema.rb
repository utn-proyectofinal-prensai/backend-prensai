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

ActiveRecord::Schema[8.0].define(version: 2025_10_17_001000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "ai_configurations", force: :cascade do |t|
    t.string "key", null: false
    t.jsonb "value"
    t.string "value_type", null: false
    t.string "display_name", null: false
    t.text "description"
    t.boolean "enabled", default: true, null: false
    t.string "reference_type"
    t.boolean "internal", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enabled"], name: "index_ai_configurations_on_enabled"
    t.index ["internal"], name: "index_ai_configurations_on_internal"
    t.index ["key"], name: "index_ai_configurations_on_key", unique: true
  end

  create_table "clipping_news", force: :cascade do |t|
    t.bigint "clipping_id", null: false
    t.bigint "news_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["clipping_id", "news_id"], name: "index_clipping_news_on_clipping_id_and_news_id", unique: true
    t.index ["clipping_id"], name: "index_clipping_news_on_clipping_id"
    t.index ["news_id"], name: "index_clipping_news_on_news_id"
  end

  create_table "clipping_reports", force: :cascade do |t|
    t.bigint "clipping_id", null: false
    t.text "content", null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "reviewer_id"
    t.bigint "creator_id"
    t.index ["clipping_id"], name: "index_clipping_reports_on_clipping_id", unique: true
    t.index ["creator_id"], name: "index_clipping_reports_on_creator_id"
    t.index ["reviewer_id"], name: "index_clipping_reports_on_reviewer_id"
  end

  create_table "clippings", force: :cascade do |t|
    t.string "name", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.bigint "creator_id", null: false
    t.bigint "topic_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "metrics", default: {}, null: false
    t.bigint "reviewer_id"
    t.index ["creator_id"], name: "index_clippings_on_creator_id"
    t.index ["end_date"], name: "index_clippings_on_end_date"
    t.index ["metrics"], name: "index_clippings_on_metrics", using: :gin
    t.index ["reviewer_id"], name: "index_clippings_on_reviewer_id"
    t.index ["start_date"], name: "index_clippings_on_start_date"
    t.index ["topic_id"], name: "index_clippings_on_topic_id"
  end

  create_table "dashboard_snapshots", force: :cascade do |t|
    t.string "context", default: "global", null: false
    t.jsonb "data", default: {}, null: false
    t.datetime "generated_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["context", "generated_at"], name: "index_dashboard_snapshots_on_context_and_generated_at"
  end

  create_table "flipper_features", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_flipper_features_on_key", unique: true
  end

  create_table "flipper_gates", force: :cascade do |t|
    t.string "feature_key", null: false
    t.string "key", null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feature_key", "key", "value"], name: "index_flipper_gates_on_feature_key_and_key_and_value", unique: true
  end

  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.jsonb "serialized_properties"
    t.text "on_finish"
    t.text "on_success"
    t.text "on_discard"
    t.text "callback_queue_name"
    t.integer "callback_priority"
    t.datetime "enqueued_at"
    t.datetime "discarded_at"
    t.datetime "finished_at"
    t.datetime "jobs_finished_at"
  end

  create_table "good_job_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id", null: false
    t.text "job_class"
    t.text "queue_name"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.text "error"
    t.integer "error_event", limit: 2
    t.text "error_backtrace", array: true
    t.uuid "process_id"
    t.interval "duration"
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
    t.index ["process_id", "created_at"], name: "index_good_job_executions_on_process_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "state"
    t.integer "lock_type", limit: 2
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "key"
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "queue_name"
    t.integer "priority"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "performed_at"
    t.datetime "finished_at"
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id"
    t.text "concurrency_key"
    t.text "cron_key"
    t.uuid "retried_good_job_id"
    t.datetime "cron_at"
    t.uuid "batch_id"
    t.uuid "batch_callback_id"
    t.boolean "is_discrete"
    t.integer "executions_count"
    t.text "job_class"
    t.integer "error_event", limit: 2
    t.text "labels", array: true
    t.uuid "locked_by_id"
    t.datetime "locked_at"
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key", "created_at"], name: "index_good_jobs_on_concurrency_key_and_created_at"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at_cond", where: "(cron_key IS NOT NULL)"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at_cond", unique: true, where: "(cron_key IS NOT NULL)"
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at", where: "((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL))"
    t.index ["labels"], name: "index_good_jobs_on_labels", where: "(labels IS NOT NULL)", using: :gin
    t.index ["locked_by_id"], name: "index_good_jobs_on_locked_by_id", where: "(locked_by_id IS NOT NULL)"
    t.index ["priority", "created_at"], name: "index_good_job_jobs_for_candidate_lookup", where: "(finished_at IS NULL)"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["priority", "scheduled_at"], name: "index_good_jobs_on_priority_scheduled_at_unfinished_unlocked", where: "((finished_at IS NULL) AND (locked_by_id IS NULL))"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "jwt_denylists", force: :cascade do |t|
    t.string "jti", null: false
    t.datetime "exp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylists_on_jti", unique: true
  end

  create_table "mention_news", force: :cascade do |t|
    t.bigint "mention_id", null: false
    t.bigint "news_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mention_id", "news_id"], name: "index_mention_news_on_mention_id_and_news_id", unique: true
    t.index ["mention_id"], name: "index_mention_news_on_mention_id"
    t.index ["news_id"], name: "index_mention_news_on_news_id"
  end

  create_table "mentions", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "enabled", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_mentions_on_name", unique: true
  end

  create_table "news", force: :cascade do |t|
    t.string "title", null: false
    t.string "publication_type"
    t.date "date", null: false
    t.string "support", null: false
    t.string "media", null: false
    t.string "section"
    t.string "author"
    t.string "interviewee"
    t.string "link", null: false
    t.integer "audience_size"
    t.decimal "quotation", precision: 10, scale: 2, default: "0.0"
    t.string "valuation"
    t.string "political_factor"
    t.text "plain_text"
    t.bigint "topic_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "creator_id"
    t.bigint "reviewer_id"
    t.index ["created_at"], name: "index_news_on_created_at"
    t.index ["creator_id"], name: "index_news_on_creator_id"
    t.index ["date"], name: "index_news_on_date"
    t.index ["link"], name: "index_news_on_link", unique: true
    t.index ["media"], name: "index_news_on_media"
    t.index ["publication_type"], name: "index_news_on_publication_type"
    t.index ["reviewer_id"], name: "index_news_on_reviewer_id"
    t.index ["topic_id"], name: "index_news_on_topic_id"
    t.index ["valuation"], name: "index_news_on_valuation"
  end

  create_table "settings", force: :cascade do |t|
    t.string "key", null: false
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_settings_on_key", unique: true
  end

  create_table "topics", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.boolean "enabled", default: true, null: false
    t.boolean "crisis", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_topics_on_name", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.boolean "allow_password_change", default: false, null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "first_name", default: ""
    t.string "last_name", default: ""
    t.string "username", default: ""
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "role", default: "user", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "clipping_news", "clippings"
  add_foreign_key "clipping_news", "news"
  add_foreign_key "clipping_reports", "clippings"
  add_foreign_key "clipping_reports", "users", column: "creator_id"
  add_foreign_key "clipping_reports", "users", column: "reviewer_id"
  add_foreign_key "clippings", "topics"
  add_foreign_key "clippings", "users", column: "creator_id"
  add_foreign_key "clippings", "users", column: "reviewer_id"
  add_foreign_key "mention_news", "mentions"
  add_foreign_key "mention_news", "news"
  add_foreign_key "news", "topics"
  add_foreign_key "news", "users", column: "creator_id"
  add_foreign_key "news", "users", column: "reviewer_id"
end
