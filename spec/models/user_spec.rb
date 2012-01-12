require 'spec_helper'

describe User do
  before(:each) do
    @attr = { 
      :name => "David", 
      :email => "David@fakemail.com",
      :password => "foobar",
      :password_confirmation => "foobar" 
    }
  end

  it "should create a new instance given valid attributes" do
    User.create(@attr)
  end

  it "should require a name" do
    no_user_name = User.new(@attr.merge(:name => ""))
    no_user_name.should_not be_valid
  end

  it "should require an email" do
    no_email_address = User.new(@attr.merge(:email => ""))
    no_email_address.should_not be_valid
  end

  it "should reject names that are too long" do
    long_name = "a" * 51
    long_name_user = User.new(@attr.merge(:name => long_name))
    long_name_user.should_not be_valid
  end

  it "should accept valid email addresses" do
    valid_emails = %w[david@gmail.com ma_tt@pooki.org icecream.rock@ridesociable.com]
    valid_emails.each do |email|
      valid_email_user = User.new(@attr.merge(:email => email))
      valid_email_user.should be_valid
    end
  end

  it "should not accept invalid email addresses" do
    invalid_emails = %w[wrong@wrong,com stillwrong_at_wrong.com thirdwrong@ccc.]
    invalid_emails.each do |email|
      invalid_email_user = User.new(@attr.merge(:email => email))
      invalid_email_user.should_not be_valid
    end
  end

  it "should not accept duplicate email addresses" do
    User.create!(@attr)
    duplicate_email_user = User.new(@attr)
    duplicate_email_user.should_not be_valid
  end

  it "should not accept duplicate email addresses up to case" do
    upcase_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcase_email))
    duplicate_email_user = User.new(@attr)
    duplicate_email_user.should_not be_valid
  end

  describe "password validations" do
    it "should require a password" do
      User.new(@attr.merge(:password => "", :password_confirmation => "")).should_not be_valid
    end

    it "should require a matching confirmation" do
      User.new(@attr.merge(:password_confirmation => "brokenpassword")).should_not be_valid
    end

    it "should not accept passwords that are too short" do
      short_pass = "a" * 5
      short_pass_attr = @attr.merge(:password => short_pass, :password_confirmation => short_pass)
      User.new(short_pass_attr).should_not be_valid
    end

    it "should not accept passwords that are too long" do
      long_pass = "a" * 41
      long_pass_attr = @attr.merge(:password => long_pass, :password_confirmation => long_pass)
      User.new(long_pass_attr).should_not be_valid
    end
  end

  describe "password encryption" do
    before(:each) do
      @user = User.create!(@attr)
    end

    it "should recognize an encrypted_password attribute" do
      @user.should respond_to(:encrypted_password)
    end

    it "should set the encrypted_password" do
      @user.encrypted_password.should_not be_blank
    end

    describe "has_password? method" do
      it "should return true on password match" do
        @user.has_password?(@attr[:password]).should be_true
      end

      it "should return false on no password match" do
        @user.has_password?("invalidpassword").should be_false
      end

      describe "authenticate method" do
        it "should return nil on incorrect email/password combination" do
          wrong_pass_user = User.authenticate(@attr[:email], "wrongpass")
          wrong_pass_user.should be_nil
        end

        it "should return nil on email not found" do
          wrong_email_user = User.authenticate("invalid@email.com", @attr[:password])
          wrong_email_user.should be_nil
        end

        it "should return the user on email password match" do
          match_user = User.authenticate(@attr[:email], @attr[:password])
          match_user.should == @user
        end
      end
    end
  end

  describe "admin attribute" do
    before(:each) do
      @user = User.create!(@attr)
    end

    it "should respond to admin" do
      @user.should respond_to(:admin)
    end

    it "should not be admin by default" do
      @user.should_not be_admin
    end

    it "should be able to be switched to admin" do
      @user.toggle!(:admin)
      @user.should be_admin
    end
  end

  describe "post association" do
    before(:each) do
      @user = User.create!(@attr)
      @post1 = Factory(:post, :user => @user, :created_at => 2.days.ago)
      @post2 = Factory(:post, :user => @user, :created_at => 2.hours.ago)
    end

    it "should recognize the post attr" do
      @user.should respond_to(:posts)
    end

    it "should return the posts in the right order" do
      @user.posts.should == [@post2, @post1]
    end

    it "destroying user should destroy associated posts" do
      @user.destroy
      [@post1, @post2].each do |post|
        Post.find_by_id(post.id).should be_nil
      end
    end

    describe "post feed" do
      it "should respond to feed" do
        @user.should respond_to(:feed)
      end

      it "should include the users posts" do
        @user.feed.include?(@post1).should be_true
      end

      it "should include other uses posts" do
        @post3 = Factory(:post, :user => Factory(:user, :email => Factory.next(:email)))
        @user.feed.include?(@post3).should be_true
      end
    end
  end

  describe "pairs" do
    before(:each) do
      @user = User.create!(@attr)
      @wing = User.Factory(:user)
    end

    it "should respond to the pairs attribute" do
      @user.should respond_to(:pairs)
    end

    it "should respond to the direct_pairs attribute" do
      @user.should respond_to(:direct_pairs)
    end
     
    it "should respond to the inverse_pairs attribute" do
      @user.should respond_to(:inverse_pairs)
    end

    it "should respond to pending pairs" do
      @user.should respond_to(:pending_pairs)
    end

    it "should respond to requested pairs" do
      @user.should respond_to(:requested_pairs)
    end

    it "should respond to wings method" do
      @user.should respond_to(:wings)
    end

    it "should respond to :direct_wings" do
      @user.should respond_to(:direct_wings)
    end

    it "should respond to :inverse_wings" do
      @user.should respond_to(:inverse_wings)
    end

    it "should have a wing? method" do
      @user.should respond_to(:wing?)
    end

    it "should respond to request_wing!" do
      @user.should respond_to(:request_wing!)
    end
    
    it "should respond to remove wing!" do
      @user.should respond_to(:remove_wing!)
    end

    describe "wings method" do
      before(:each) do
        @inverse_wing = Factory(:user, :email => Factory.next(:email))
        @non_wing_user = Factory(:user, :email => Factory.next(:email))
        @pair1 = Factory(:pair, :user => @user, :wing => @wing, :accepted => true)
        @pair2 = Factory(:pair, :user => @inverse_wing, :wing => @user, :accepted => true)
      end

      it "should list all wings" do
        @user.wings.should include(@wing, @inverse_wing)
      end

      it "should not include non-wings" do
        @user.wings.should_not include(@non_wing_user)
      end

      it "should include all direct wings" do
        @user.wings.should include(*@user.direct_wings)
      end

      it "should include all inverse wings" do
        @user.wings.should include(*@user.inverse_wings)
      end
    end

    describe "adding wings" do
      before(:each) do
        @requester = Factory(:user, :email => Factory.next(:email))
      end

      it "request_wing! should add a user to the requestees list"
      it "accept_wing! should add a user from requested_wings to wings"
    end
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

