class Post < ActiveRecord::Base
  attr_accessible :content

  belongs_to :user

  default_scope :order => 'posts.created_at DESC'

  validates :content, :presence => true, :length => {:maximum => 400}
  validates :user_id, :presence => true
end
