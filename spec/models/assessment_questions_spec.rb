require 'spec_helper'

describe AssessmentQuestion do
  before do
    @assessment_question = FactoryGirl.create(:assessment_question)
  end

  subject { @assessment_question }

  # Basic attributes
  it { should respond_to(:title) }
  it { should respond_to(:question_body) }
  it { should respond_to(:answers) }
  it { should respond_to(:questionType) }
  it { should be_valid}

  describe "with an invalid json" do
    before{@assessment_question.answers = "invalid"}
    it{should_not be_valid}
  end

  describe "with multiple correct answers on radio bubbles" do
    before{@assessment_question.answers = '[{"text":"one","correct":true},{"text":"two","correct":true}]'}
    before{@assessment_question.questionType = "singleAnswer"}
    it{should_not be_valid}
  end

  describe "without an answer" do
    before{@assessment_question.answers = '[{"text":"one","correct":false},{"text":"two","correct":false}]'}
    it{should_not be_valid}
  end

  describe "with an invalid text key" do
    before{@assessment_question.answers = '[{"INVALID":"one","correct":false},{"text":"two","correct":false}]'}
    it{should_not be_valid}
  end

  describe "with an invalid correct key" do
    before{@assessment_question.answers = '[{"text":"one","correct":false},{"text":"two","INVALID":false}]'}
    it{should_not be_valid}
  end

  describe "with an invalid questionType" do
    before {@assessment_question.questionType = "invalid"}
    it{should_not be_valid}
  end
end