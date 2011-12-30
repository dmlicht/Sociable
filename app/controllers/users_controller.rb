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
      redirect_to @user
      flash[:success] = "Welcome to RideSociable. Your carriage awaits."
    else
      @sub_title = "Sign up"
      render 'new'
    end
  end
end
