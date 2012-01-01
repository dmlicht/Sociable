class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
    @sub_title = @user.name
  end

  def new
    @user = User.new
    @sub_title = "Sign up"
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to RideSociable. Your carriage awaits."
      redirect_to @user
    else
      @sub_title = "Sign up"
      render 'new'
    end
  end
end
