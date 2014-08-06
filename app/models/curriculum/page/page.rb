class Page < ActiveRecord::Base
  resourcify
  include Curriculumify
  validates :title, presence: true, length: {maximum: 100}, allow_blank: false


  attr_accessor :visible_to
end
