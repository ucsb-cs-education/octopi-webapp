class TaskResponse < ActiveRecord::Base
  belongs_to :school_class
  belongs_to :student
  belongs_to :task
  has_one :laplaya_file, foreign_key: :laplaya_file_id
  has_many :assessment_question_responses
  accepts_nested_attributes_for :assessment_question_responses

  #def type_must_be_correct
   # errors.add(:type, "must be either laplaya_task_response or assessment_task_response") unless type=="laplaya_task_response" || type=="assessment_task_response"
  #end

end