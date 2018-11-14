class IMyouMigration < ActiveRecord::Migration<%= migration_version %>
  def self.up
    create_table :imyou_nicknames do |t|
      t.references :model, polymorphic: true
      t.string :name, null: false
      t.timestamps
    end
    add_index :imyou_nicknames, :name
    add_index :imyou_nicknames,
              [ :name, :model_id, :model_type ],
              unique: true,
              name: 'imyou_unique_name'
  end

  def self.down
    remove_index :imyou_nicknames, :name
    remove_index :imyou_nicknames,
                 [ :name, :model_id, :model_type ],
                 name: 'imyou_unique_name'
    drop_table :imyou_nicknames
  end
end