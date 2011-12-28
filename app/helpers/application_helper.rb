module ApplicationHelper

  #returns title on per application basis
  def title
    base_title = "Sociable"
    if @sub_title.nil?
      base_title
    else
      "#{base_title} | #{@sub_title}"
    end
  end
end
