require 'digest'
class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessible :name, :email, :password, :password_confirmation

  has_many :posts, :dependent => :destroy

  has_many :direct_pairs, :dependent => :destroy, :class_name => "Pair", :conditions => ['accepted = ?', true], :foreign_key => "user_id"
  has_many :inverse_pairs, :dependent => :destroy, :class_name => "Pair", :conditions => ['accepted = ?', true], :foreign_key => "wing_id"

  has_many :pending_pairs, :dependent => :destroy, :class_name => "Pair", :conditions => ['accepted = ?', false], :foreign_key => "user_id"
  has_many :requested_pairs, :dependent => :destroy, :class_name => "Pair", :conditions => ['accepted = ?', false], :foreign_key => "wing_id"

  has_many :direct_wings, :through => :direct_pairs, :source => :wing
  has_many :inverse_wings, :through => :inverse_pairs, :source => :user

  #has_many :pairs, :dependent => :destroy
  #has_many :inverse_pairs, :dependent => :destroy, :class_name => "Pair", :foreign_key => "wing_id"
  #has_many :direct_wings, :through => :pairs, :conditions => ['accepted = ?', true], :source => :wing
  #has_many :inverse_wings, :through => :inverse_pairs, :conditions => ['accepted = ?', true], :source => :user

  #has_many :pending_wings, :through => :pairs, :conditions => ['accepted = ?', false], :source => :wing
  #has_many :requested_wings, :through => :inverse_pairs, :conditions => ['accepted = ?', false], :source => :user

  email_format = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :name, :presence => true,
            :length => { :maximum => 50 }

  validates :email, :presence => true,
            :format => { :with => email_format },
            :uniqueness => { :case_sensitive => false }

  validates :password, :presence => true,
            :length => { :within => 6..40 },
            :confirmation => true,
            :on => :create

  before_save :encrypt_password

  def has_password?(submitted_password)
    encrypted_password == encrypt(submitted_password)
  end

  def self.authenticate(submitted_email, submitted_password)
    user = find_by_email(submitted_email)
    return nil if user.nil?
    return user if user.has_password?(submitted_password)
  end

  def self.authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)
    (user && user.salt == cookie_salt) ? user : nil
  end

  def feed
    Post.all
  end

  def wings
    direct_wings | inverse_wings
  end

  def pairs
    direct_pairs | inverse_pairs
  end

  def get_pair(wing)
    direct_pairs.find_by_wing_id(wing) || inverse_pairs.find_by_user_id(wing)
  end

  def wing?(wing)
    direct_pairs.find_by_wing_id(wing) or inverse_pairs.find_by_user_id(wing)
  end

  def pending_wing?(wing)
    pending_pairs.find_by_wing_id(wing)
  end

  def requested_wing?(wing)
    requested_pairs.find_by_user_id(wing)
  end

  def request_wing!(wing)
    new_pair = pending_pairs.build
    new_pair.wing = wing
    new_pair.save!
  end

  def accept_wing!(wing)
    pair = requested_pairs.find_by_user_id(wing.id)
    pair.accepted = true
    pair.save!
  end

  def remove_wing!(wing)
    pair = pairs.find_by_wing_id(wing.id) | inverse_pairs.find_by_user_id(wing.id)
    pair.destroy unless pair.nil?
  end
  private

    def encrypt_password
      self.salt = make_salt if new_record?
      self.encrypted_password = encrypt(password)
    end

    def encrypt(string)
      secure_hash("#{salt}--#{string}")
    end

    def make_salt
      secure_hash("#{Time.now.utc}--#{password}")
    end

    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end
end
# == Schema Information
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(255)
#  salt               :string(255)
#  admin              :boolean         default(FALSE)
#

