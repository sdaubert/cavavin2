class CreateBottles < ActiveRecord::Migration[5.2]
  def change
    create_table :bottles do |t|
      t.integer :millesime_id
      t.integer :br_id, null: true
      t.integer :pos, null: true

      t.timestamps
    end
  end
end
