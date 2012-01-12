require 'spec_helper'

describe Post do
  before(:each) do
    @user = Factory(:user)
    @attr = { :content => "test content"}
  end

  it "should create a new instance given valid attributes" do
    @user.posts.create!(@attr)
  end

  describe "user associations" do
    before(:each) do
      @post = @user.posts.create!(@attr)
    end

    it "should have a user attribute" do
      @post.should respond_to(:user)
    end

    it "should have the right user associated" do
      @post.user.should == @user
      @post.user_id.should == @user.id
    end
  end

  describe "validations" do
    it "should require a user id" do
      Post.new(@attr).should_not be_valid
    end

    it "should be less than 400 chars" do
      @user.posts.build(:content => "a" * 401).should_not be_valid
    end

    it "should contain nonblank chars" do
      @user.posts.build(:content => "     ").should_not be_valid
    end
  end
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

