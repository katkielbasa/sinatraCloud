require 'sequel'
require 'pg'

DB = Sequel.connect(ENV['DATABASE_URL'])

DB.create_table? :users do
  primary_key :id
  String :name, uniq: true, null: false
  String :email, uniq: true, null: false
  String :password, uniq: true, null: false
  String :salt, uniq: false, null: false
  TrueClass :admin, uniq: false, default: false
end

require_relative 'models/user'
