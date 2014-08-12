class Page < ActiveRecord::Base
  resourcify
  include Curriculumify
  validates :title, presence: true, length: {maximum: 100}, allow_blank: false
  has_paper_trail :on=> [:update, :destroy]

  attr_accessor :visible_to
end
