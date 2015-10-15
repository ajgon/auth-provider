class AddOptionsToApplication < ActiveRecord::Migration
  def change
    add_column :oauth_applications, :allowed_cors, :text
    add_column :oauth_applications, :slug, :string
    add_column :oauth_applications, :base, :boolean, null: false, default: false
  end
end
