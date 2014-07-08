require 'spec_helper'

shared_examples_for Pages::PagesController do

  describe "updating an existing one with ajax" do

    let(:another_myself) { FactoryGirl.create(controller_symbol) }
    it "should not increment the count" do
      myself #Call the variable so that it is evaluated outside the xhr block
      another_myself
      expect do
        xhr :patch, :update, id: myself.id,
            controller_symbol =>
                {title: another_myself.title,
                 teacher_body: another_myself.teacher_body,
                 student_body: another_myself.student_body}
      end.to_not change(myModel, :count)
    end

    it "should update the original" do
      xhr :patch, :update, id: myself.id,
          controller_symbol =>
              {title: another_myself.title,
               teacher_body: "new teacher body",
               student_body: "new student body"}
      myself.reload
      expect(myself.title).to eq(another_myself.title)
      expect(myself.teacher_body).to eq("new teacher body")
      expect(myself.student_body).to eq("new student body")
    end

    it "should respond with success: no content" do
      xhr :patch, :update, id: myself.id,
          controller_symbol =>
              {title: another_myself.title,
               teacher_body: "new teacher body",
               student_body: "new student body"}
      myself.reload
      expect(response.status).to eq(200)
    end
  end

  describe "updating without permission" do
    let(:teacher){ FactoryGirl.create(:staff, :teacher)}
    let(:another_myself) { FactoryGirl.create(controller_symbol) }

    before do
      sign_in_as_staff(teacher)
    end

    it "should not update the original" do
      xhr :patch, :update, id: myself.id,
          controller_symbol =>
              {title: another_myself.title,
               teacher_body: "new teacher body",
               student_body: "new student body"}
      myself.reload
      expect(myself.title).to_not eq(another_myself.title)
      expect(myself.teacher_body).to_not eq("new teacher body")
      expect(myself.student_body).to_not eq("new student body")
    end

    it "should return an error" do
      xhr :patch, :update, id: myself.id,
          controller_symbol =>
              {title: another_myself.title,
               teacher_body: "new teacher body",
               student_body: "new student body"}
      myself.reload
      expect(response.status).to eq(403)
    end
  end

end


shared_examples "a controller that can create and destroy" do
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

  describe "destroying with Ajax" do
    it "should decrement the count" do
      myself
      expect do
        xhr :delete, :destroy, id: myself.id
      end.to change(myModel, :count).by(-1)
    end
  end

  describe "attempting to make changes without permission" do
    let(:teacher){ FactoryGirl.create(:staff, :teacher)}
    before do
      sign_in_as_staff(teacher)
    end

    describe "creating without permission" do

      it "should not increment the count" do
        myself #Call the variable so that it is evaluated outside the xhr block
        expect do
          xhr :post, :create, parent_id_symbol => myself.parent.id, controller_symbol => {title:"example", teacher_body:"example", student_body:"example"}
        end.to_not change(myModel, :count)
      end

      it "should respond with an error" do
        xhr :post, :create, parent_id_symbol => myself.parent.id, controller_symbol => {title:"example", teacher_body:"example", student_body:"example"}
        expect(response.status).to eq(403)
      end
    end

    describe "destroying without permission" do
      it "should not decrement the count" do
        myself
        expect do
          xhr :delete, :destroy, id: myself.id
        end.to_not change(myModel, :count)
      end
    end
  end
end

shared_examples "a controller with children" do
  describe "updating with children count" do
    let(:another_myself) { FactoryGirl.create(controller_symbol) }
    let(:a_child_one){FactoryGirl.create(my_children, controller_symbol => myself) }
    let(:a_child_two){FactoryGirl.create(my_children, controller_symbol => myself) }
    let(:a_child_three){FactoryGirl.create(my_children, controller_symbol => myself) }

    it "should not increment the count" do
      myself #Call the variable so that it is evaluated outside the xhr block
      another_myself
      a_child_one
      a_child_two
      a_child_three
      expect do
        xhr :patch, :update, id: myself.id,
            controller_symbol =>
                {title: another_myself.title,
                 teacher_body: another_myself.teacher_body,
                 student_body: another_myself.student_body},
            children_order:build_children_order_string
      end.to change(myModel, :count).by(0)
    end

    it "should change the children order" do
      myself #Call the variable so that it is evaluated outside the xhr block
      another_myself
      a_child_one
      a_child_two
      a_child_three
      original_order = build_children_order_string

      #here i reverse the order of the children_order string
      new_order = "&"+ original_order.split('&').reverse.reduce("") do |sum,value|
        sum+=original_order[value]+"&"
      end.gsub('&&','')

      xhr :patch, :update, id: myself.id,
          controller_symbol =>
              {title: another_myself.title,
               teacher_body: another_myself.teacher_body,
               student_body: another_myself.student_body},
          children_order:new_order
      myself.reload
      expect(build_children_order_string).to_not eq(original_order)
      expect(build_children_order_string).to eq(new_order)
      expect(response.status).to eq(200)
    end
  end
end

def build_children_order_string
  return myself.children.pluck(:id).reduce("") do |sum,value|
    if sum.nil?
      sum = ""
    else
      sum += "&"
    end
    sum += "#{my_children.to_s}[]=#{value}"
   end
end