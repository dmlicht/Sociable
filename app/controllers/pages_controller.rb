class PagesController < ApplicationController
  def home
    @sub_title = "Home"
  end

  def contact
    @sub_title = "Contact"
  end

  def about
    @sub_title = "About"
  end

end
