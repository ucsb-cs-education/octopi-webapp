require 'spec_helper'


describe "Task responses page", type: :feature do

  let(:assessment_task) { FactoryGirl.create(:assessment_task) }
  let(:feedback_assessment_task) { FactoryGirl.create(:assessment_task, give_feedback: true) }
  let(:super_staff) { FactoryGirl.create(:staff, :super_staff) }
  let(:teacher) { FactoryGirl.create(:staff, :teacher) }
  let(:student) { FactoryGirl.create(:student) }
  let(:student_2) { FactoryGirl.create(:student) }
  let(:another_class) { FactoryGirl.create(:school_class) }
  let(:another_student) { FactoryGirl.create(:student) }

  subject { page }

  before do
    2.times {
      assessment_task.assessment_questions << FactoryGirl.create(:assessment_question)
      feedback_assessment_task.assessment_questions << FactoryGirl.create(:assessment_question)
    }
    student
    student_2
    another_class
    another_student.school_classes = []
    another_student.school_classes << another_class
    Student.all.each { |s|
      Unlock.create!(student: s, school_class: s.school_classes.first, unlockable: assessment_task)
      Unlock.create!(student: s, school_class: s.school_classes.first, unlockable: feedback_assessment_task)
      response_1 = AssessmentTaskResponse.create!(student: s, school_class: s.school_classes.first, task: assessment_task)
      response_2 = AssessmentTaskResponse.create!(student: s, school_class: s.school_classes.first, task: feedback_assessment_task)
      response_1.assessment_question_responses << AssessmentQuestionResponse.create!(task_response_id: response_1.id,
                                                                                     assessment_question: assessment_task.assessment_questions.first,
                                                                                     selected: "[1]")
      response_1.assessment_question_responses << AssessmentQuestionResponse.create!(task_response_id: response_1.id,
                                                                                     assessment_question: assessment_task.assessment_questions.second,
                                                                                     selected: "[0]")
      response_2.assessment_question_responses << AssessmentQuestionResponse.create!(task_response_id: response_2.id,
                                                                                     assessment_question: feedback_assessment_task.assessment_questions.first,
                                                                                     selected: "[1]")
      response_2.assessment_question_responses << AssessmentQuestionResponse.create!(task_response_id: response_2.id,
                                                                                     assessment_question: feedback_assessment_task.assessment_questions.second,
                                                                                     selected: "[0]")
    }
  end

  shared_examples_for 'the task response index page with no task param' do
    it { should have_link("#{CurriculumPage.find(assessment_task.curriculum_id)}", :href => curriculum_page_path(assessment_task.curriculum_id)) }
    it { should have_content("#{feedback_assessment_task.title}") }
    describe "after clicking on one of the tasks" do
      before do
        click_link "#{feedback_assessment_task.title}"
      end

      it "should bring you to the list of student responses for that task" do
        uri = URI.parse(current_url)
        expect("#{uri.path}?#{uri.query}").to eq(task_responses_path(task: feedback_assessment_task))
      end

      it { should have_link("#{student.school_classes.first}", :href => school_class_path(student.school_classes.first)) }
      it { should have_link("#{feedback_assessment_task.title}", :href => assessment_task_path(feedback_assessment_task)) }
      it { should have_link("", :href => task_responses_path) }
      it { should have_link("#{student.name}", :href => task_response_path(student.task_responses.second)) }
      it { should have_link("#{student_2.name}", :href => task_response_path(student_2.task_responses.second)) }

      describe "after click the student name link to view a single task response" do
        before do
          click_link("#{student.name}")
        end

        it "should bring you to the student response" do
          expect(current_path).to eq(task_response_path(student.task_responses.second))
        end

        it { should have_content("Correct Answer: 2 Student Answer: 2") }
        it { should have_content("Correct Answer: 2 Student Answer: 1") }
        it { should have_link("#{student.name}'s progress", :href => school_class_student_progress_path(student.school_classes.first, student)) }

        describe "after selecting another student from the dropdown", js: true do
          before do
            select("#{student_2.name}", :from => 'other-responses')
            click_button('View other student answers')
          end

          it "should bring you to the other student's response" do
            expect(current_path).to eq(task_response_path(student_2.task_responses.second))
          end
        end

      end

    end
  end

  describe "as a super staff" do
    before do
      sign_in_as_staff(super_staff)
      visit task_responses_path
    end

    it_behaves_like 'the task response index page with no task param'

    describe "that can view anything" do
      describe "at the task response index page" do
        describe "with no task param" do
          it { should have_content("#{assessment_task.title}") }
          it { should have_content("#{feedback_assessment_task.title}") }
        end
        describe "with the task param of a task response that provides feedback" do
          before do
            visit task_responses_path(task: feedback_assessment_task)
          end
          it { should have_link("#{student.school_classes.first}", :href => school_class_path(student.school_classes.first)) }
          it { should have_link("#{another_class.name}", :href => school_class_path(another_student.school_classes.first)) }
          it { should have_link("#{another_student.name}", :href => task_response_path(another_student.task_responses.second)) }
        end
        describe "with the task param of a task response that does not provide feedback" do
          before do
            visit task_responses_path(task: assessment_task)
          end
          it { should have_link("#{student.school_classes.first}", :href => school_class_path(student.school_classes.first)) }
          it { should have_link("#{another_class.name}", :href => school_class_path(another_student.school_classes.first)) }
          it { should have_link("#{student.name}", :href => task_response_path(student.task_responses.first)) }
          it { should have_link("#{student_2.name}", :href => task_response_path(student_2.task_responses.first)) }
          it { should have_link("#{another_student.name}", :href => task_response_path(another_student.task_responses.first)) }
        end
      end
      describe "at the task response show page" do
        describe "after visiting a task response to a task that provides feedback" do
          before do
            visit task_response_path(student.task_responses.second)
          end
          it "should correctly get to the page" do
            expect(current_path).to eq(task_response_path(student.task_responses.second))
          end
        end
        describe "after visiting a task response to a task that does not provide feedback" do
          before do
            visit task_response_path(student.task_responses.first)
          end
          it "should correctly get to the page" do
            expect(current_path).to eq(task_response_path(student.task_responses.first))
          end
        end
        describe "after visiting a task response in a different class" do
          describe "that does not provide feedback" do
            before do
              visit task_response_path(another_student.task_responses.first)
            end
            it "should correctly get to the page" do
              expect(current_path).to eq(task_response_path(another_student.task_responses.first))
            end
          end
          describe "that does provides feedback" do
            before do
              visit task_response_path(another_student.task_responses.second)
            end
            it "should correctly get to the page" do
              expect(current_path).to eq(task_response_path(another_student.task_responses.second))
            end
          end
        end
      end
    end

  end

  describe "as a teacher" do
    before do
      sign_in_as_staff(teacher)
      visit task_responses_path
    end

    it_behaves_like 'the task response index page with no task param'

    describe "that can only view things viewable by teachers" do
      describe "at the task response index page" do
        describe "with no task param" do
          it { should_not have_content("#{assessment_task.title}") }
          it { should have_content("#{feedback_assessment_task.title}") }
        end
        describe "with the task param of a task response that provides feedback" do
          before do
            visit task_responses_path(task: feedback_assessment_task)
          end
          it { should have_link("#{student.school_classes.first}", :href => school_class_path(student.school_classes.first)) }
          it { should_not have_link("#{another_class.name}", :href => school_class_path(another_student.school_classes.first)) }
          it { should_not have_link("#{another_student.name}", :href => task_response_path(another_student.task_responses.second)) }
        end
        describe "with the task param of a task response that does not provide feedback" do
          before do
            visit task_responses_path(task: assessment_task)
          end

          it { should have_content("You are not authorized to access this page.") }
          it "should deny access" do
            expect(current_path).to eq(root_path)
          end
        end
      end
      describe "at the task response show page" do
        describe "after visiting a task response to a task that provides feedback" do
          before do
            visit task_response_path(student.task_responses.second)
          end
          it "should correctly get to the page" do
            expect(current_path).to eq(task_response_path(student.task_responses.second))
          end
        end
        describe "after visiting a task response to a task that does not provide feedback" do
          before do
            visit task_response_path(student.task_responses.first)
          end
          it { should have_content("You are not authorized to access this page.") }
          it "should deny access" do
            expect(current_path).to eq(root_path)
          end
        end
        describe "after visiting a task response in a different class" do
          describe "that does not provide feedback" do
            before do
              visit task_response_path(another_student.task_responses.first)
            end
            it { should have_content("You are not authorized to access this page.") }
            it "should deny access" do
              expect(current_path).to eq(root_path)
            end
          end
          describe "that provides feedback" do
            before do
              visit task_response_path(another_student.task_responses.second)
            end
            it { should have_content("You are not authorized to access this page.") }
            it "should deny access" do
              expect(current_path).to eq(root_path)
            end
          end
        end
      end
    end

  end

end