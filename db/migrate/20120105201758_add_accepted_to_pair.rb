class AddAcceptedToPair < ActiveRecord::Migration
  def change
    add_column :pairs, :accepted, :boolean, default: false
  end
end
