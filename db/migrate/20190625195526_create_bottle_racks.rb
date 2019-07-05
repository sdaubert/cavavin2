class CreateBottleRacks < ActiveRecord::Migration[5.2]
  def change
    create_table :bottle_racks do |t|
      t.string :name
      t.integer :lines
      t.integer :columns

      t.timestamps
    end
  end
end
