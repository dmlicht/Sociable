class SessionsController < ApplicationController
  def new
    @sub_title = "Sign in"
  end

  def create
    user = User.authenticate(params[:session][:email], params[:session][:password])
    if user.nil?
      flash.now[:error] = "Invalid credentials. Try again pookie."
      @sub_title = "Sign in"
      render 'new'
    else
      sign_in user
      redirect_back_or root_path
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end
end
