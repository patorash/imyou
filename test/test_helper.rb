# frozen_string_literal: true

require 'minitest/autorun'
require 'active_record'

# database_cleaner 1～2系のどちらでも動くようにするため、パスを修正
require 'database_cleaner'
require 'imyou'

Dir["#{Dir.pwd}/test/internal/app/models/*.rb"].sort.each { |f| require f }

ActiveRecord::Base.establish_connection('adapter' => 'sqlite3', 'database' => ':memory:')
ActiveRecord::Schema.define do
  create_table :imyou_nicknames do |t|
    t.references :model, polymorphic: true
    t.string :name, null: false
    t.timestamps null: false
  end
  add_index :imyou_nicknames, :name
  add_index :imyou_nicknames,
            %i[name model_id model_type],
            unique: true,
            name: 'imyou_unique_name'

  create_table :users, force: true do |t|
    t.string :name, null: false
    t.timestamps null: false
  end

  create_table :not_users, force: true do |t|
    t.string :name, null: false
    t.timestamps null: false
  end

  create_table :no_name_users, force: true
end

DatabaseCleaner.strategy = :transaction

module Minitest
  class Spec
    before :each do
      DatabaseCleaner.start
    end

    after :each do
      DatabaseCleaner.clean
    end
  end
end

# @see https://stackoverflow.com/questions/20329387/how-to-assert-the-contents-of-an-array-indifferent-of-the-ordering
module Minitest
  module Assertions
    def assert_matched_arrays(exp, act)
      exp_ary = exp.to_ary

      assert_kind_of Array, exp_ary
      act_ary = act.to_ary

      assert_kind_of Array, act_ary
      assert_equal exp_ary.sort, act_ary.sort
    end
  end
end

module Minitest
  module Expectations
    infect_an_assertion :assert_matched_arrays, :must_match_array
  end
end
