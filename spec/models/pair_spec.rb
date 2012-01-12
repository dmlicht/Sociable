require 'spec_helper'

describe Pair do
  before(:each) do
    @user = Factory(:user)
    @wing = Factory(:user, :email => Factory.next(:email))
    @pair = @user.direct_pairs.build
    @pair.wing = @wing
  end

  it "should be able to create a pair" do
    @pair.save!
  end

  describe "wingman connections" do
    it "should respond to user" do
      @pair.should respond_to(:user)
    end

    it "should have a user" do
      @pair.user.should == @user
    end

    it "should respond to wing" do
      @pair.should respond_to(:wing)
    end

    it "should have a wing" do
      @pair.wing == @wing
    end
  end

  describe "validations" do
    it "should require a user_id" do
      @pair.user_id = nil
      @pair.should_not be_valid
    end

    it "should require a pair_id" do
      @pair.wing_id = nil
      @pair.should_not be_valid
    end
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

