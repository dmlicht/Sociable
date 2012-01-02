require 'spec_helper'

describe "SigninForwardings" do
  it "should redirect you to the requested page after you sign in" do
    user = Factory(:user)
    visit edit_user_path(user)
    fill_in :email, :with => user.email
    fill_in :password, :with => user.password
    click_button
    response.should render_template('users/edit')
  end
end
