module Pages::PagesHelper

  def get_time(object)
    t = object.updated_at.in_time_zone('Pacific Time (US & Canada)')
    t.strftime("#{t.day.ordinalize} %B, %Y %I:%M %p")
  end

  def children_visible_to_me(page)
    if can? :update, @page
      page.children
    else
      page.children.teacher_visible
    end
  end

  def delete_all_responses_confirmation_box_text
    text = 'confirmationPrompt(\'This will delete all student responses to this task in ALL schools.\','
    text+= "'"+current_staff.email.html_safe+"')"
    text.html_safe
  end

end
