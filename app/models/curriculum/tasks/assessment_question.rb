require 'xml'
class AssessmentQuestion < ActiveRecord::Base
  resourcify
  belongs_to :assessment_task, foreign_key: :assessment_task_id
  alias_attribute :parent, :assessment_task
  alias_attribute :children, :answers
  validate :JSON_validator
  validate :valid_answer_type
  has_paper_trail on: [:update, :destroy]
  acts_as_list scope: [:assessment_task_id]

  include Versionate
  include Curriculumify
  undef :visible_to
  undef :visible_to=


  private
  def self.answer_types
    [OpenStruct.new(val: 'singleAnswer', label:'One Correct'),
     OpenStruct.new(val: 'multipleAnswers', label:'Multiple Correct'),
     OpenStruct.new(val: 'freeResponse', label: 'Free Response')]
  end

  def JSON_validator
    begin
      @info_array = JSON.parse(answers)
    rescue
      @info_array = 'Bad String'
    end
    if answers_should_be_valid_JSON
      if an_answer_exists
        radios_have_one_answer
      end
    end
  end

  def radios_have_one_answer
    if question_type == 'singleAnswer'
      num_true = 0
      @info_array.each do |x|
        if x['correct']
          num_true+=1;
        end
      end
      if num_true > 1
        errors.add(:answers, 'must only have one answer if its using radios')
        return false
      end
    end
    true
  end

  def an_answer_exists
    has_answer = false
    if question_type == 'freeResponse'
      true
    else
      @info_array.each do |x|
        if x['correct']
          has_answer = true
        end
      end
      if has_answer
        true
      else
        errors.add(:answers, 'must have at least one correct answer')
        false
      end
    end
  end

  def valid_answer_type
    unless (question_type == 'singleAnswer' || question_type == 'multipleAnswers' || question_type == 'freeResponse')
      errors.add(:answers, 'answer type must be singleAnswer or multipleAnswers or freeResponse')
    end
  end

  def answers_should_be_valid_JSON
    if @info_array.is_a?(Array)
      @info_array.each do |x|
        unless x.has_key? 'correct'
          errors.add(:answers, "answers must have 'correct' key")
          return false
        end
        unless x.has_key? 'text'
          errors.add(:answers, "answers must have 'text' key")
          return false
        end
      end
    else
      errors.add(:answers, 'answers must be a JSON array')
      return false
    end
    true
  end

end
