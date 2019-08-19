ActiveRecord::Schema.define do
  create_table :imyou_nicknames do |t|
    t.references :model, polymorphic: true
    t.string :name, null: false
    t.timestamps null: false
  end
  add_index :imyou_nicknames, :name
  add_index :imyou_nicknames,
            [ :name, :model_id, :model_type ],
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

  create_table :no_name_users, force: true do |t|
  end
end
