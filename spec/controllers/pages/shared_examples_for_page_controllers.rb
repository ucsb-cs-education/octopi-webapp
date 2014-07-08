require 'spec_helper'

shared_examples_for Pages::PagesController do
  describe "creating with ajax" do
    it "should increment the count" do
      myself #Call the variable so that it is evaluated outside the xhr block
      expect do
        xhr :post, :create, parent_id_symbol => myself.parent.id, controller_symbol => {title:"example", teacher_body:"example", student_body:"example"}
      end.to change(myModel, :count).by(1)
    end

    it "should respond with success: created" do
      xhr :post, :create, parent_id_symbol => myself.parent.id, controller_symbol => {title:"example", teacher_body:"example", student_body:"example"}
      expect(response.status).to eq(201)
    end

    describe "that is invalid" do
      describe "because it has an empty title" do
        it "should not increase the count" do
          myself #Call the variable so that it is evaluated outside the xhr block
          expect do
            xhr :post, :create, parent_id_symbol => myself.parent.id, controller_symbol => {title:"", teacher_body:"example", student_body:"example"}
          end.not_to change(myModel, :count)
        end

        it "should throw an error" do
          xhr :post, :create, parent_id_symbol => myself.parent.id, controller_symbol => {title:"", teacher_body:"example", student_body:"example"}
          expect(response.status).to eq(400)
        end
      end
    end

  end

=begin
  describe "deleting one with ajax" do
    it "should decrement the amount" do
      expect do
        xhr
      end.to change(myModel, :count).by(1)
    end
  end
=end

  describe "updating an existing one with ajax" do
    let(:another_myself) { FactoryGirl.create(controller_symbol) }
    it "should not increment the count" do
      myself #Call the variable so that it is evaluated outside the xhr block
      another_myself
      expect do
        xhr :patch, :update, id: myself.id, controller_symbol => {title: another_myself.title, teacher_body: another_myself.teacher_body, student_body: another_myself.student_body}
      end.to change(myModel, :count).by(1)
    end
  end
end