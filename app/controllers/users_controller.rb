class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
  end

  def new
    @sub_title = "Sign up"
  end

end
