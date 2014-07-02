require 'xml'
class AssessmentQuestion < ActiveRecord::Base
  resourcify
  belongs_to :assessment_task, foreign_key: :assessment_task_id
  alias_attribute :parent, :assessment_task
  alias_attribute :children, :answers
  after_create {update_attribute(:curriculum_id, parent.curriculum_id)}
  validate :JSON_validator
  validate :valid_answer_type

  private

  def JSON_validator
    begin
      @infoArray = JSON.parse(answers)
    rescue
      @infoArray = "Bad String"
    end
    if answers_should_be_valid_JSON()==true
      if an_answer_exists()==true
        radios_have_one_answer()
      end
    end
  end

  def update_curriculum_id
    self.curriculum_id = parent.curriculum_id
  end

  def radios_have_one_answer
    if questionType=="singleAnswer"
      numTrue = 0;
      @infoArray.each { |x|
        if x['correct']==true
          numTrue+=1;
        end
      }
      if numTrue > 1
        errors.add(:answers, "must only have one answer if its using radios")
        return false;
      end
      return true;
    end
    true
  end

  def an_answer_exists
    hasAnswer = false;
    @infoArray.each { |x|
      if x['correct'] == true
        hasAnswer = true;
      end
    }
    if(hasAnswer==true)
      return true
    else
      errors.add(:answers, "must have atleast one correct answer")
      return false
    end
  end

  def valid_answer_type
    errors.add(:answers, "answer type must be singleAnswer or multipleAnswers") unless questionType=="singleAnswer" || questionType=="multipleAnswers"
  end

  def answers_should_be_valid_JSON
    if @infoArray.is_a?(Array)
      @infoArray.each {|x|
        if !(x.has_key? 'correct')
          errors.add(:answers, "answers must have 'correct' key")
          return false;
        end
        if !(x.has_key? 'text')
          errors.add(:answers, "answers must have 'text' key")
          return false;
        end
      }
    else
      errors.add(:answers, "answers must be a JSON array")
      return false;
    end
    return true;
  end

  #validates :file_name, presence: true, length: {maximum: 50}
end