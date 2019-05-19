class CreateWlogs < ActiveRecord::Migration[5.2]
  def change
    create_table :wlogs do |t|
      t.integer :millesime_id
      t.date :date
      t.string :mvt_type
      t.integer :quantity
      t.decimal :price, precision: 8, scale: 2
      t.text :notes

      t.timestamps
    end
  end
end
