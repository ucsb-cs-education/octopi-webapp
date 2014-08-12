class TestStudent < Student
  belongs_to :staff, foreign_key: :test_student_id
end