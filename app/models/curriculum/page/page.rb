class Page < ActiveRecord::Base
  resourcify
  include Curriculumify
  include Versionate
  has_paper_trail on: [:update, :destroy]
  attr_accessor :visible_to

  def restore_page_children(id, version)
    page = self.class.find(id)
    page.restore_children(version)
  end

end
