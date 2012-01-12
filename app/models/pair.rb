class Pair < ActiveRecord::Base
  attr_accessible :interested_in
  belongs_to :user
  belongs_to :wing, :class_name => "User"

  validates :user_id, :presence => true
  validates :wing_id, :presence => true

  scope :valid, where(:accepted => true)
  scope :pending, where(:accepted => false)

  def make_valid
    self.accepted = true
  end

  def accepted?
    self.accepted == true
  end

  def member?(id)
    user_id == id or wing_id == id
  end
end
# == Schema Information
#
# Table name: pairs
#
#  id            :integer         not null, primary key
#  user_id       :integer
#  wing_id       :integer
#  created_at    :datetime
#  updated_at    :datetime
#  accepted      :boolean         default(FALSE)
#  interested_in :string(255)
#

