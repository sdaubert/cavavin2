class UpdateMillesimeYear < ActiveRecord::Migration[5.2]
  def change
    change_column_null :millesimes, :year, true
    change_column_null :garde, :year, true

    Millesime.where(year: 0).update_all(year: nil, garde: nil)
  end
end
