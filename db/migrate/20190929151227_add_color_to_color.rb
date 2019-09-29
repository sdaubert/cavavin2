class AddColorToColor < ActiveRecord::Migration[5.2]
  def change
    add_column :colors, :color, :string
  end
end
