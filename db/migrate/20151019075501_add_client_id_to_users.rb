# frozen_string_literal: true
class AddClientIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :client_id, :string, null: false
  end
end
