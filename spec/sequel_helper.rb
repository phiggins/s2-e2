require 'sequel'

DB = Sequel.sqlite

DB.create_table :users do
  primary_key :id
  String      :first_name
  String      :last_name
  String      :email
  Boolean     :admin
end

DB.create_table :posts do
  primary_key :id
  Integer     :author_id
  String      :text
end

class User < Sequel::Model
  one_to_many :posts, :key => :author_id
end

class Post < Sequel::Model
  many_to_one :author, :class => User
end
