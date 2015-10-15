class CreateOauthApplicationUsers < ActiveRecord::Migration
  def change
    create_table :oauth_application_users do |t|
      t.references :oauth_application, null: false
      t.references :user, null: false
      t.timestamps null: false
    end
    add_index :oauth_application_users, [:oauth_application_id, :user_id], unique: true, using: :btree,
                                                                           name: 'oauth_application_id_and_user_id'
  end
end
