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

ActiveRecord::Schema[7.1].define(version: 2025_06_02_090617) do
  create_table "exercices", force: :cascade do |t|
    t.integer "numero"
    t.text "mini_court"
    t.text "situation"
    t.integer "notion_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notion_id"], name: "index_exercices_on_notion_id"
  end

  create_table "notions", force: :cascade do |t|
    t.integer "numero"
    t.string "notion"
    t.integer "niveau"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "parties", force: :cascade do |t|
    t.string "timestamp"
    t.string "score"
    t.boolean "finished"
    t.integer "notion_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notion_id"], name: "index_parties_on_notion_id"
  end

  create_table "questions", force: :cascade do |t|
    t.integer "numero"
    t.string "intitule"
    t.json "choix"
    t.string "reponse"
    t.integer "exercice_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercice_id"], name: "index_questions_on_exercice_id"
  end

  create_table "reponses", force: :cascade do |t|
    t.integer "ex_num"
    t.integer "q_num"
    t.string "rep"
    t.integer "partie_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["partie_id"], name: "index_reponses_on_partie_id"
  end

  add_foreign_key "exercices", "notions"
  add_foreign_key "parties", "notions"
  add_foreign_key "questions", "exercices"
  add_foreign_key "reponses", "parties"
end
