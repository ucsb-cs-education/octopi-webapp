module ApplicationHelper
  def full_title(page_title)
    base_title = "Octopi"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  def inside_layout(parent_layout)
    view_flow.set :layout, capture { yield }
    render template: "layouts/#{parent_layout}"
  end

  def controller_classes
    current_path = ""
    controller_path.split('/').map{|x| (current_path.empty?) ? current_path = x : current_path += "-" + x  }.join(" ")
  end

end
