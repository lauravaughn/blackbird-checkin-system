class CreateAttendees < ActiveRecord::Migration[7.0]
  def change
    create_table :attendees do |t|
      t.references :event, null: false, foreign_key: true
      t.string :email, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :company
      t.string :job_title
      t.string :phone
      t.text :notes
      t.string :qr_code_token, null: false
      t.json :custom_fields, default: {}
      
      t.timestamps
    end
    
    add_index :attendees, [:event_id, :email], unique: true
    add_index :attendees, :qr_code_token, unique: true
    add_index :attendees, :email
  end
end