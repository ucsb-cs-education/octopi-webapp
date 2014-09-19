module Pages::PagesHelper

  def get_time(object)
    t = object.updated_at.in_time_zone('Pacific Time (US & Canada)')
    t.strftime("#{t.day.ordinalize} %B, %Y %I:%M %p")
  end

  def children_visible_to_me
    @page.children.accessible_by(current_ability, action_name.to_sym)
    # if can? :update, @page
    #   page.children
    # else
    #   page.children.teacher_visible
    # end
  end

  def can_update_page?
    (!@preview) && can?(:update, @page)
  end

end
