require 'spec_helper'

describe "Users" do
  describe "sign up" do
    describe "failure" do
      it "should not make a new user" do
        lambda do
          visit signup_path
          fill_in "Name", :with => ""
          fill_in "Email", :with => ""
          fill_in "Password", :with => ""
          fill_in "Confirmation", :with => ""
          click_button
          response.should render_template('users/new')
          response.should have_selector('div#error_explanation')
        end.should_not change(User, :count)
      end
    end

    describe "success" do
      it "should add a new user" do
        lambda do
          visit signup_path
          fill_in "Name", :with => "David testname"
          fill_in "Email", :with => "david@test.email.com"
          fill_in "Password", :with => "validpass"
          fill_in "Confirmation", :with => "validpass"
          click_button
          response.should have_selector("div.flash.success", :content => "Welcome")
          response.should render_template('users/show')
        end.should change(User, :count).by(1)
      end
    end
  end

  describe "sign in/out" do
    describe "success" do
      it "should sign a user in" do
        user = Factory(:user)
        visit signin_path
        fill_in :email, :with => user.email
        fill_in :password, :with => user.password
        click_button
        controller.should be_signed_in
        click_link "Sign out"
        controller.should_not be_signed_in
      end
    end

    describe "failure" do
      it "should not sign a user in" do
        visit signin_path
        fill_in :email, :with => ""
        fill_in :password, :with => ""
        click_button
        controller.should_not be_signed_in
        response.should have_selector("div.flash.error", :content => "Invalid")
      end
      
    end
  end
end
