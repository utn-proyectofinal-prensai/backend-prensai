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

ActiveRecord::Schema[8.0].define(version: 2025_08_06_040505) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_mentions", force: :cascade do |t|
    t.string "name"
    t.integer "position"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "events", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "color"
    t.boolean "is_active"
    t.json "tags"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "news", force: :cascade do |t|
    t.string "titulo"
    t.string "tipo_publicacion"
    t.string "fecha"
    t.string "soporte"
    t.string "medio"
    t.string "seccion"
    t.string "autor"
    t.string "conductor"
    t.string "entrevistado"
    t.string "tema"
    t.string "etiqueta1"
    t.string "etiqueta2"
    t.string "link"
    t.string "alcance"
    t.string "cotizacion"
    t.string "tapa"
    t.string "valoracion"
    t.string "eje_comunicacional"
    t.string "factor_politico"
    t.string "crisis"
    t.string "gestion"
    t.string "area"
    t.string "mencion1"
    t.string "mencion2"
    t.string "mencion3"
    t.string "mencion4"
    t.string "mencion5"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role"
  end
end
