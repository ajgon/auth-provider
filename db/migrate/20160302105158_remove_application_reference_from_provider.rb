# frozen_string_literal: true
class RemoveApplicationReferenceFromProvider < ActiveRecord::Migration
  def up
    remove_column :providers, :application_id
  end

  def down
    add_reference :providers, :application, index: true
  end
end
