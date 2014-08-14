class LaplayaTask < Task
  has_one :task_base_laplaya_file, foreign_key: :parent_id, dependent: :destroy
  has_one :task_completed_laplaya_file, foreign_key: :parent_id, dependent: :destroy
  has_one :laplaya_analysis_file, foreign_key: :task_id, dependent: :destroy
  alias_attribute :children, :task_base_laplaya_file

  def is_accessible?(student, school_class)
    if visible_to_students
      status = get_visibility_status_for(student, school_class)
      status == :visible || status == :completed
    end
  end

  def get_visibility_status_for(student, school_class)
    response = find_response_for(student, school_class)
    if response.nil? || !response.unlocked
      :locked
    else
      result = :visible
      if response.present?
        unless response.laplaya_file.nil?
          result = :in_progress
        end
        if response.completed
          result = :completed
        end
      end
      result
    end
  end

  def create_basic_response_for(student, school_class)
    LaplayaTaskResponse.create!(student: student, school_class: school_class, task: self, unlocked: (prerequisites.empty? ? true : false))
  end


end