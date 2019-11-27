class CreatePreferences < ActiveRecord::Migration[5.2]
  def change
    create_table :preferences do |t|
      t.string :setting
      t.string :stype
      t.string :value
    end

    reversible do |dir|
      dir.up do
        Preference.create(setting: 'show_wines_without_bottles',
                          stype: 'boolean',
                          value: 'false')
      end
      dir.down do
        Preference.destroy_all
      end
    end
  end
end
