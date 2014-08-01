module Pages::PagesHelper

  def teacher_view?
    false
  end

  def get_time(object)
    t = object.updated_at.in_time_zone('Pacific Time (US & Canada)')
    t.strftime("#{t.day.ordinalize} %B, %Y %I:%M %p")
  end
end
