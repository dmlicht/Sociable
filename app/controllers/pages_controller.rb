class PagesController < ApplicationController
  def home
    @sub_title = "Home"
    if signed_in?
      @post = Post.new
      @feed_items = Kaminari.paginate_array(current_user.feed).page(params[:page])
    end
  end

  def contact
    @sub_title = "Contact"
  end

  def about
    @sub_title = "About"
  end

end
