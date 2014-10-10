class Page < ActiveRecord::Base
  resourcify
  include Curriculumify
  include Versionate
  has_paper_trail on: [:update, :destroy]
  attr_accessor :visible_to

end
