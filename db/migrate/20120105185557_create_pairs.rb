class CreatePairs < ActiveRecord::Migration
  def change
    create_table :pairs do |t|
      t.integer :user_id
      t.integer :wing_id

      t.timestamps
    end
    add_index :pairs, :user_id
    add_index :pairs, :wing_id
  end
end
