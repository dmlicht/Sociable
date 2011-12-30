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
#

