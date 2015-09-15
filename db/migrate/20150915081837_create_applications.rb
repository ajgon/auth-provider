class CreateApplications < ActiveRecord::Migration
  def change
    create_table :applications do |t|
      t.references :user, index: true
      t.string :name, null: false
      t.string :slug
      t.timestamps null: false
    end
  end
end
