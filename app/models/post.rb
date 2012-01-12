class Post < ActiveRecord::Base
  attr_accessible :content

  belongs_to :user

  default_scope :order => 'posts.created_at DESC'

  validates :content, :presence => true, :length => {:maximum => 400}
  validates :user_id, :presence => true
end
# == Schema Information
#
# Table name: posts
#
#  id         :integer         not null, primary key
#  content    :string(255)
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

