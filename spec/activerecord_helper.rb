# References:
# http://www.themomorohoax.com/2009/03/15/activerecord-sqlite-in-memory-db-without-rails
# http://apidock.com/rails/v2.3.8/ActiveRecord/Migration

require 'active_record'

if ActiveRecord::VERSION::MAJOR > 2
  $stderr.puts <<-OMGDANGER
  Using ActiveRecord #{ActiveRecord::VERSION::STRING}.
  This was tested with ActiveRecord > 3. YMMV.
  OMGDANGER
end

ActiveRecord::Base.establish_connection(
  :adapter  => "sqlite3",
  :database => ":memory:" )

class TestSchema < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.integer :id
      t.string  :first_name
      t.string  :last_name
      t.string  :email
      t.boolean :admin
    end

    create_table :posts do |t|
      t.integer :id
      t.integer :author_id
      t.string  :text
    end
  end
end

ActiveRecord::Migration.suppress_messages do
  TestSchema.up
end

class User < ActiveRecord::Base
  has_many :posts, :foreign_key => :author_id
end

class Post < ActiveRecord::Base
  belongs_to :author, :class_name => 'User'
end
