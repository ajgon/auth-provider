# frozen_string_literal: true
class CreateApplicationProviders < ActiveRecord::Migration
  def change
    create_table :application_providers do |t|
      t.references :application
      t.references :provider
    end
    add_index :application_providers, [:application_id, :provider_id]
  end
end
