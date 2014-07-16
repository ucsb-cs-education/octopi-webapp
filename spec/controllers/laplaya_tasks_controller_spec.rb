require 'spec_helper'

describe Pages::LaplayaTasksController, type: :controller do
  let(:super_staff) { FactoryGirl.create(:staff, :super_staff) }
  let(:curriculum) { FactoryGirl.create(:curriculum_page) }
  let(:curriculum_designer) { FactoryGirl.create(:staff, :curriculum_designer, curriculum: curriculum) }
  let(:teacher) { FactoryGirl.create(:staff, :teacher) }

  shared_examples_for "creating a laplaya task with ajax" do
    let(:laplaya_task) { FactoryGirl.create(:laplaya_task, curriculum_id: curriculum.id) }
    it "should increment the TaskBaseLaplayaFile count" do
      laplaya_task #Call the variable so that it is evaluated outside the xhr block
      expect do
        xhr :post, :create,
            activity_page_id: laplaya_task.parent.id,
            laplaya_task: {
                title: laplaya_task.title,
                teacher_body: laplaya_task.teacher_body,
                student_body: laplaya_task.student_body
            }
      end.to change(TaskBaseLaplayaFile, :count).by(1)
    end
    it "should increment the LaplayaTask count" do
      laplaya_task #Call the variable so that it is evaluated outside the xhr block
      expect do
        xhr :post, :create,
            activity_page_id: laplaya_task.parent.id,
            laplaya_task: {
                title: laplaya_task.title,
                teacher_body: laplaya_task.teacher_body,
                student_body: laplaya_task.student_body
            }
      end.to change(LaplayaTask, :count).by(1)
    end

    it "should respond with success: created" do
      xhr :post, :create,
          activity_page_id: laplaya_task.parent.id,
          laplaya_task: {
              title: laplaya_task.title,
              teacher_body: laplaya_task.teacher_body,
              student_body: laplaya_task.student_body
          }
      expect(response.status).to eq(201)
    end

    it "should create an object with the proper title" do
      xhr :post, :create,
          activity_page_id: laplaya_task.parent.id,
          laplaya_task: {
              title: laplaya_task.title + "Helloworld",
              teacher_body: laplaya_task.teacher_body,
              student_body: laplaya_task.student_body
          }
      expect(LaplayaTask.last.title).to eq(laplaya_task.title+"Helloworld")
    end

    it "should create an object with the proper teacher_body" do
      xhr :post, :create,
          activity_page_id: laplaya_task.parent.id,
          laplaya_task: {
              title: laplaya_task.title,
              teacher_body: laplaya_task.teacher_body + "Helloworld",
              student_body: laplaya_task.student_body
          }
      expect(LaplayaTask.last.teacher_body).to eq(laplaya_task.teacher_body+"Helloworld")
    end

    describe "without a title" do
      it "should fail" do
        xhr :post, :create,
            activity_page_id: laplaya_task.parent.id,
            laplaya_task: {
                teacher_body: laplaya_task.teacher_body,
                student_body: laplaya_task.student_body
            }
        expect(response.status).to eq(400)
      end

      it "should not change the TaskBaseLaplayaFile count" do
        laplaya_task
        expect do
          xhr :post, :create,
              activity_page_id: laplaya_task.parent.id,
              laplaya_task: {
                  teacher_body: laplaya_task.teacher_body,
                  student_body: laplaya_task.student_body
              }
        end.to_not change(TaskBaseLaplayaFile, :count)
      end

      it "should not change the LaplayaTask count" do
        laplaya_task
        expect do
          xhr :post, :create,
              activity_page_id: laplaya_task.parent.id,
              laplaya_task: {
                  teacher_body: laplaya_task.teacher_body,
                  student_body: laplaya_task.student_body
              }
        end.to_not change(LaplayaTask, :count)
      end
    end

    describe "with unathorized parameters" do
      let(:another_curriculum) { FactoryGirl.create(:curriculum_page) }
      it "should not use the unathorized parameters" do
        xhr :post, :create,
            activity_page_id: laplaya_task.parent.id,
            laplaya_task: {
                title: laplaya_task.title,
                teacher_body: laplaya_task.teacher_body,
                student_body: laplaya_task.student_body,
                curriculum_id: another_curriculum.id
            }
        expect(LaplayaTask.last.curriculum_id).to_not eq(another_curriculum.id)
      end
    end
  end

  describe "creating a LaplayaTask as a super_staff" do
    let(:laplaya_file) { FactoryGirl.create(:laplaya_file, owner: staff) }
    before(:each) do
      sign_in_as(super_staff)
    end
    include_examples "creating a laplaya task with ajax"
  end

  describe "creating a LaplayaTask as a curriculum_designer" do
    let(:laplaya_file) { FactoryGirl.create(:laplaya_file, owner: staff) }
    before(:each) do
      sign_in_as(curriculum_designer)
    end
    include_examples "creating a laplaya task with ajax"
  end

end