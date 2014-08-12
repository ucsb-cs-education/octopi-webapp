class AddTestStudentReferenceToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :test_student, index: true
  end
end
