class PostsController < ApplicationController
  before_filter :authenticate
  before_filter :authorized_user, :only => :destroy

  def create
    @post = current_user.posts.build(params[:post])
    if @post.save
      flash[:success] = "Post created. Enlighten the world!"
      redirect_to root_path
    else
      @feed_items = []
      @pair_requests = []
      render 'pages/home'
    end
  end

  def destroy
    @post.destroy
    flash[:success] = "Post blasted! Nice work sheriff."
    redirect_back_or root_path
  end

  private
    def authorized_user
      @post = Post.find(params[:id])
      redirect_to root_path unless current_user.admin? or current_user?(@post.user)
    end
end
