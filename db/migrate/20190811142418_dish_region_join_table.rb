class DishRegionJoinTable < ActiveRecord::Migration[5.2]
  def change
    create_table :dras do |t|
      t.integer :dish_id
      t.integer :region_id
      t.integer :color_id

      t.timestamps
    end
  end
end
