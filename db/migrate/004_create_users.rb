class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :role, default: 'organizer'
      t.integer :main_app_user_id
      t.datetime :last_login_at
      
      t.timestamps
    end
    
    add_index :users, :email, unique: true
    add_index :users, :main_app_user_id, unique: true
  end
end