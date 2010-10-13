require 'mini_factory'
require 'sequel'

DB = Sequel.sqlite

DB.create_table :users do
  primary_key :id
  String :first_name
  String :last_name
end

class User < Sequel::Model ; end

require 'minitest/spec'
MiniTest::Unit.autorun

describe MiniFactory do
  it "should provide the most basic syntax" do
    MiniFactory.define User do |u|
      u.first_name = 'John'
      u.last_name  = 'Doe'
    end

    u = MiniFactory(:user)
    u.first_name.must_equal "John"
    u.last_name.must_equal "Doe"
  end
end
