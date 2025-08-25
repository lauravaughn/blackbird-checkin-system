class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.string :name, null: false
      t.text :description
      t.datetime :date, null: false
      t.string :venue, null: false
      t.text :venue_address
      t.string :event_code
      t.integer :expected_attendees, default: 0
      t.json :settings, default: {}
      
      t.timestamps
    end
    
    add_index :events, :date
    add_index :events, :event_code, unique: true
  end
end