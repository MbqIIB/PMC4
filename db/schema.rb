# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160111213543) do

  create_table "agroups", force: true do |t|
    t.string "name"
  end

  create_table "agroups_mfiles", id: false, force: true do |t|
    t.integer "mfile_id"
    t.integer "agroup_id"
  end

  add_index "agroups_mfiles", ["agroup_id"], name: "index_agroups_mfiles_on_agroup_id", using: :btree
  add_index "agroups_mfiles", ["mfile_id"], name: "index_agroups_mfiles_on_mfile_id", using: :btree

  create_table "albums", force: true do |t|
    t.integer  "artist_id",             null: false
    t.string   "name",                  null: false
    t.datetime "date_added",            null: false
    t.string   "year",       limit: 20
  end

  add_index "albums", ["artist_id", "name"], name: "artist_id", unique: true, using: :btree

  create_table "artists", force: true do |t|
    t.string   "name",        null: false
    t.datetime "date_added",  null: false
    t.string   "browse_name"
  end

  add_index "artists", ["name"], name: "name", unique: true, using: :btree

  create_table "attris", force: true do |t|
    t.string  "name"
    t.integer "agroup_id"
    t.integer "id_sort"
    t.integer "parent_id"
    t.string  "keycode"
  end

  add_index "attris", ["agroup_id"], name: "index_attris_on_agroup_id", using: :btree
  add_index "attris", ["keycode"], name: "index_attris_on_keycode", using: :btree

  create_table "attris_mfiles", id: false, force: true do |t|
    t.integer "mfile_id"
    t.integer "attri_id"
  end

  add_index "attris_mfiles", ["attri_id"], name: "index_attris_mfiles_on_attri_id", using: :btree
  add_index "attris_mfiles", ["mfile_id"], name: "index_attris_mfiles_on_mfile_id", using: :btree

  create_table "collection", force: true do |t|
    t.string "path", limit: 500, null: false
  end

  create_table "folders", force: true do |t|
    t.integer "storage_id"
    t.string  "mpath"
    t.string  "lfolder"
    t.integer "mfile_id"
  end

  add_index "folders", ["storage_id"], name: "index_folders_on_storage_id", using: :btree

  create_table "indexer", force: true do |t|
    t.datetime "last_modified", null: false
  end

  create_table "locations", force: true do |t|
    t.string   "name"
    t.string   "uri"
    t.string   "description"
    t.integer  "typ"
    t.integer  "storage_id"
    t.boolean  "inuse"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "prefix"
    t.integer  "mfile_id"
  end

  create_table "matches", force: true do |t|
    t.string   "pattern"
    t.string   "extract"
    t.string   "tag"
    t.string   "filter"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "result"
  end

  create_table "media_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mfiles", force: true do |t|
    t.integer  "folder_id"
    t.string   "filename"
    t.datetime "modified"
    t.date     "mod_date"
    t.integer  "mtype"
  end

  add_index "mfiles", ["folder_id"], name: "index_mfiles_on_folder_id", using: :btree
  add_index "mfiles", ["modified"], name: "index_mfiles_on_modified", using: :btree

  create_table "mtypes", force: true do |t|
    t.string   "name"
    t.string   "icon"
    t.string   "model"
    t.boolean  "has_file"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "packlocations", force: true do |t|
    t.string "name"
    t.string "filepath"
    t.string "webpath"
    t.string "tnfilepath"
    t.string "tnwebpath"
  end

  create_table "packs", force: true do |t|
    t.string  "name"
    t.integer "packlocation_id"
  end

  create_table "play_log", force: true do |t|
    t.integer  "track_id"
    t.datetime "date_played",                 null: false
    t.integer  "user_id"
    t.boolean  "scrobbled",   default: false, null: false
  end

  add_index "play_log", ["track_id"], name: "ix_play_log_track_id", using: :btree

  create_table "playlist_tracks", force: true do |t|
    t.integer "playlist_id"
    t.integer "track_id"
  end

  create_table "playlists", force: true do |t|
    t.string   "name",          null: false
    t.datetime "date_created",  null: false
    t.datetime "date_modified", null: false
    t.integer  "user_id"
  end

  add_index "playlists", ["name"], name: "name", unique: true, using: :btree

  create_table "properties", force: true do |t|
    t.string "name",  limit: 100, null: false
    t.string "value",             null: false
  end

  add_index "properties", ["name"], name: "name", unique: true, using: :btree

  create_table "props", force: true do |t|
    t.integer "mfile_id"
    t.integer "width"
    t.integer "height"
    t.integer "pixels"
    t.integer "size"
    t.string  "md5"
  end

  add_index "props", ["md5"], name: "index_props_on_md5", using: :btree
  add_index "props", ["mfile_id"], name: "index_props_on_mfile_id", using: :btree

  create_table "request_log", force: true do |t|
    t.integer  "user_id"
    t.string   "ip_address",      limit: 16, null: false
    t.datetime "date_of_request",            null: false
    t.string   "request_url",                null: false
    t.string   "user_agent",                 null: false
    t.string   "referer",                    null: false
    t.string   "cookies",                    null: false
  end

  create_table "selections", force: true do |t|
    t.string   "name"
    t.string   "what",       limit: 1
    t.integer  "seize"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "par"
  end

  create_table "selitems", force: true do |t|
    t.integer "objid"
    t.integer "next_id"
    t.integer "prev_id"
    t.integer "selection_id"
    t.string  "what",         limit: 1
  end

  add_index "selitems", ["selection_id"], name: "index_selitems_on_selection_id", using: :btree

  create_table "sessions", force: true do |t|
    t.string   "code",         limit: 10, null: false
    t.integer  "user_id",                 null: false
    t.datetime "date_created",            null: false
  end

  create_table "storages", force: true do |t|
    t.string  "name",        limit: 20
    t.integer "no",                      default: 1
    t.string  "filepath",    limit: 100
    t.string  "webpath",     limit: 50
    t.string  "filepath_tn", limit: 100
    t.string  "webpath_tn",  limit: 50
    t.integer "mtype"
  end

  create_table "tracks", force: true do |t|
    t.integer  "artist_id",                 null: false
    t.integer  "album_id"
    t.string   "name",                      null: false
    t.string   "path",          limit: 500, null: false
    t.integer  "length",                    null: false
    t.datetime "date_added",                null: false
    t.integer  "collection_id",             null: false
    t.integer  "track_no",      limit: 2
  end

  add_index "tracks", ["artist_id", "album_id", "name"], name: "artist_id", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "name",         limit: 50,                 null: false
    t.string   "pass",         limit: 32,                 null: false
    t.string   "email",                                   null: false
    t.datetime "date_created",                            null: false
    t.boolean  "is_admin",                default: false, null: false
    t.string   "is_active",    limit: 1,  default: "1",   null: false
  end

  add_index "users", ["name"], name: "name", unique: true, using: :btree

end
