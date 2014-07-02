class AssessmentTask < Task
  resourcify
  has_many :assessment_questions
  alias_attribute :children, :assessment_questions
end