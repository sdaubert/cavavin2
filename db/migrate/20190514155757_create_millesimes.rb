class CreateMillesimes < ActiveRecord::Migration[5.2]
  def change
    create_table :millesimes do |t|
      t.integer :year
      t.integer :garde
      t.integer :wine_id
      t.text :notes

      t.timestamps
    end
  end
end
