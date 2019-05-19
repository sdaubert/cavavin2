class CreateRegions < ActiveRecord::Migration[5.2]
  def change
    create_table :regions do |t|
      t.references :country, foreign_key: true
      t.string :name
      t.integer :parent_id, :null => true, :index => true
      t.integer :lft, :null => false, :index => true
      t.integer :rgt, :null => false, :index => true
      t.integer :depth, :null => false, :default => 0
      t.integer :children_count, :null => false, :default => 0

      t.timestamps
    end
  end
end
