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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120229153919) do

  create_table "access_token_request_objects", :force => true do |t|
    t.integer  "access_token_id"
    t.integer  "request_object_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "access_token_scopes", :force => true do |t|
    t.integer  "access_token_id"
    t.integer  "scope_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "access_tokens", :force => true do |t|
    t.integer  "account_id"
    t.integer  "client_id"
    t.string   "token"
    t.datetime "expires_at"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "access_tokens", ["token"], :name => "index_access_tokens_on_token", :unique => true

  create_table "accounts", :force => true do |t|
    t.string   "identifier"
    t.datetime "last_logged_in_at"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "accounts", ["identifier"], :name => "index_accounts_on_identifier", :unique => true

  create_table "authorization_request_objects", :force => true do |t|
    t.integer  "authorization_id"
    t.integer  "request_object_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "authorization_scopes", :force => true do |t|
    t.integer  "authorization_id"
    t.integer  "scope_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "authorizations", :force => true do |t|
    t.integer  "account_id"
    t.integer  "client_id"
    t.string   "code"
    t.string   "nonce"
    t.string   "redirect_uri"
    t.datetime "expires_at"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "authorizations", ["code"], :name => "index_authorizations_on_code", :unique => true

  create_table "clients", :force => true do |t|
    t.integer  "account_id"
    t.string   "identifier"
    t.string   "secret"
    t.string   "name"
    t.string   "jwks_uri"
    t.string   "sector_identifier"
    t.string   "redirect_uris"
    t.boolean  "dynamic",             :default => false
    t.boolean  "native",              :default => false
    t.boolean  "ppid",                :default => false
    t.datetime "expires_at"
    t.text     "raw_registered_json"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "clients", ["identifier"], :name => "index_clients_on_identifier", :unique => true

  create_table "connect_facebook", :force => true do |t|
    t.integer  "account_id"
    t.string   "identifier"
    t.string   "access_token"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "connect_fakes", :force => true do |t|
    t.integer  "account_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "connect_google", :force => true do |t|
    t.integer  "account_id"
    t.string   "identifier"
    t.string   "access_token"
    t.text     "id_token"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "id_token_request_objects", :force => true do |t|
    t.integer  "id_token_id"
    t.integer  "request_object_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "id_tokens", :force => true do |t|
    t.integer  "account_id"
    t.integer  "client_id"
    t.string   "nonce"
    t.datetime "expires_at"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "pairwise_pseudonymous_identifiers", :force => true do |t|
    t.integer  "account_id"
    t.string   "identifier"
    t.string   "sector_identifier"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "request_objects", :force => true do |t|
    t.text     "jwt_string"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "scopes", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "scopes", ["name"], :name => "index_scopes_on_name", :unique => true

end
