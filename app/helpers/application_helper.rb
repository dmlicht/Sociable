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

  def tagline
    base = "Bring your wing"
    tag_decider = rand(2)
    if tag_decider == 0
      base + "man"
    else
      base + "women"
    end
  end
end
