class CreateRegionsColorsJoinTable < ActiveRecord::Migration[5.2]
  def change
    create_join_table :regions, :colors do |t|
      t.index [:region_id, :color_id]
      # t.index [:color_id, :region_id]
    end
  end
end
