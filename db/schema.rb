# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110118132615) do

  create_table "data_firmen", :force => true do |t|
    t.string  "Firma",                         :null => false
    t.string  "Ansprechpartner",               :null => false
    t.string  "Strasse",                       :null => false
    t.integer "Hausnummer",       :limit => 2, :null => false
    t.string  "HausnummerZusatz",              :null => false
    t.integer "PLZ",              :limit => 3, :null => false
    t.string  "Ort",                           :null => false
    t.string  "Telefon",                       :null => false
    t.string  "Fax",                           :null => false
    t.string  "e-Mail",                        :null => false
    t.string  "WWW",                           :null => false
  end

  create_table "data_unternehmen", :force => true do |t|
    t.string  "Firma",                         :null => false
    t.string  "Ansprechpartner",               :null => false
    t.string  "Strasse",                       :null => false
    t.integer "Hausnummer",       :limit => 2, :null => false
    t.string  "HausnummerZusatz",              :null => false
    t.integer "PLZ",              :limit => 3, :null => false
    t.string  "Ort",                           :null => false
    t.string  "Telefon",                       :null => false
    t.string  "Fax",                           :null => false
    t.string  "e-Mail",                        :null => false
    t.string  "WWW",                           :null => false
  end

  create_table "permissions", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "access"
    t.string   "tabelle"
    t.string   "spalte"
  end

  create_table "permissions_users", :id => false, :force => true do |t|
    t.integer  "permission_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                              :null => false
    t.string   "crypted_password",                   :null => false
    t.string   "password_salt",                      :null => false
    t.string   "persistence_token",                  :null => false
    t.string   "single_access_token",                :null => false
    t.string   "perishable_token",                   :null => false
    t.integer  "login_count",         :default => 0, :null => false
    t.integer  "failed_login_count",  :default => 0, :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin"
    t.boolean  "active"
    t.string   "name"
    t.string   "telefon"
  end

end
