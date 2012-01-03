class UsersController < ApplicationController
  before_filter :authenticate, :only => [:edit, :update, :index, :destroy]
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :admin_user, :only => :destroy

  def index
    @sub_title = "Users"
    @users = User.page(params[:page]) 
  end

  def show
    @user = User.find(params[:id])
    @posts = @user.posts
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

  def edit
    @sub_title = "Edit"
  end

  def update
    @user.name = params[:user][:name]
    @user.email = params[:user][:email]
    if @user.save
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      @sub_title = "Edit"
      render 'edit'
    end
  end

  def destroy
    dead_user = User.find(params[:id])
    username = dead_user.name
    dead_user.destroy
    flash[:success] = "User destroyed. Take that #{username}"
    redirect_to users_path
  end

  private

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end
end
