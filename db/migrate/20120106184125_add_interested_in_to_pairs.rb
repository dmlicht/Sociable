class AddInterestedInToPairs < ActiveRecord::Migration
  def change
    add_column :pairs, :interested_in, :string
  end
end
