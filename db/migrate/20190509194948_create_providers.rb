class CreateProviders < ActiveRecord::Migration[5.2]
  def change
    create_table :providers do |t|
      t.string :name
      t.string :address
      t.string :zip
      t.string :city
      t.integer :country_id
      t.string :phone
      t.string :web
      t.string :email
      t.text :notes

      t.timestamps
    end
  end
end
