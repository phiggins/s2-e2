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
  before do
    # XXX Lame hacks...
    MiniFactory.factories = {}
  end

  it "should support basic factory_girl use case" do
    #MiniFactory.define :user do |u|
    MiniFactory.define :user do |u|
      u.first_name 'John'
      u.last_name  'Doe'
    end

    u = MiniFactory(:user)
    u.first_name.must_equal "John"
    u.last_name.must_equal "Doe"
  end

  describe ".define" do
    it "should accept a model" do
      MiniFactory.define User do |u|
        u.first_name 'John'
        u.last_name  'Doe'
      end

      MiniFactory.factories.has_key?(:user).must_equal true
    end

    it "should accept a symbol" do
      MiniFactory.define :user do |u|
        u.first_name 'John'
        u.last_name  'Doe'
      end

      MiniFactory.factories.has_key?(:user).must_equal true
    end

    it "should accept a string" do
      MiniFactory.define "user" do |u|
        u.first_name 'John'
        u.last_name  'Doe'
      end

      MiniFactory.factories.has_key?(:user).must_equal true
    end
  end
end
