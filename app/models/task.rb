class Task < ActiveRecord::Base
  resourcify
  belongs_to :activity_page, foreign_key: :page_id
  acts_as_list scope: [:type, :page_id]
  # include CustomModelNaming
  # self.param_key = :feed
  # self.route_key = :feeds
  alias_attribute :parent, :activity_page
  include Curriculumify
  validates :title, presence: true, length: {maximum: 100}, allow_blank: false

end
