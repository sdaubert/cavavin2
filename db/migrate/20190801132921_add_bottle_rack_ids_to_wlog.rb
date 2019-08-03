class AddBottleRackIdsToWlog < ActiveRecord::Migration[5.2]
  def change
    add_column :wlogs, :br_id, :integer, null: true
    add_column :wlogs, :pos, :string, null: true
    add_column :wlogs, :move_to_br_id, :integer, null: true
    add_column :wlogs, :move_to_pos, :string, null: true
  end
end
