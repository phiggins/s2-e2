require 'mini_factory'
require 'sequel'

DB = Sequel.sqlite

DB.create_table :users do
  primary_key :id
  String :first_name
  String :last_name
  Boolean :admin
end

class User < Sequel::Model ; end

require 'minitest/spec'
MiniTest::Unit.autorun

describe MiniFactory do
  before do
    MiniFactory.clear_factories!
  end

  it "should support basic factory_girl use case" do
    MiniFactory.define :user do |u|
      u.first_name 'John'
      u.last_name  'Doe'
      u.admin false
    end

    u = MiniFactory(:user)
    u.first_name.must_equal "John"
    u.last_name.must_equal "Doe"
    u.admin.must_equal false
  end

  describe ".define" do
    it "should allow specifying the class with :class option" do
      MiniFactory.define :admin, :class => User do |u|
        u.first_name 'Admin'
        u.last_name  'User'
        u.admin true
      end

      MiniFactory(:admin).must_be_kind_of User
    end

    it "should accept a model" do
      MiniFactory.define User do |u|
        u.first_name 'John'
        u.last_name  'Doe'
        u.admin false
      end

      MiniFactory(:user).must_be_kind_of User
    end

    it "should accept a symbol" do
      MiniFactory.define :user do |u|
        u.first_name 'John'
        u.last_name  'Doe'
        u.admin false
      end

      MiniFactory(:user).must_be_kind_of User
    end

    it "should accept a string" do
      MiniFactory.define "user" do |u|
        u.first_name 'John'
        u.last_name  'Doe'
        u.admin false
      end

      MiniFactory(:user).must_be_kind_of User
    end
  end
end
