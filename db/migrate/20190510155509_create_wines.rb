class CreateWines < ActiveRecord::Migration[5.2]
  def change
    create_table :wines do |t|
      t.string :domain
      t.boolean :effervescent
      t.boolean :organic
      t.integer :color_id
      t.integer :region_id
      t.integer :producer_id, null: true
      t.integer :provider_id, null: true
      t.text :notes

      t.timestamps
    end
  end
end
