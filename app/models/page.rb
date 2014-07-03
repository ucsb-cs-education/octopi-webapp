class Page < ActiveRecord::Base
  resourcify
  include Curriculumify
  validate :title_length

  def title_length
    errors.add(:Pages, "must have a title.") unless title.length>0
  end


end
