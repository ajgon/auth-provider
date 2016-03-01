# frozen_string_literal: true
class CreateProviders < ActiveRecord::Migration
  def change
    create_table :providers do |t|
      t.string :type
      t.references :application, index: true
      t.boolean :enabled, null: false, default: false
      t.string :client_id
      t.string :client_secret
      t.timestamps null: false
    end
  end
end
