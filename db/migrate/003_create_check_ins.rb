class CreateCheckIns < ActiveRecord::Migration[7.0]
  def change
    create_table :check_ins do |t|
      t.references :attendee, null: false, foreign_key: true
      t.boolean :checked_in, default: false
      t.datetime :checked_in_at
      t.string :check_in_method, default: 'qr_code'
      t.string :checked_by
      t.text :notes
      
      t.timestamps
    end
    
    add_index :check_ins, :attendee_id, unique: true
    add_index :check_ins, :checked_in_at
    add_index :check_ins, :check_in_method
  end
end