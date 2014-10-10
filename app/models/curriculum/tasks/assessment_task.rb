class AssessmentTask < Task
  has_many :assessment_questions, -> { order('position ASC') }, foreign_key: :assessment_task_id, dependent: :destroy
  alias_attribute :children, :assessment_questions

  def update_with_children(params, ids)
    update_with_children_helper(AssessmentQuestion, params, ids)
  end

  def is_accessible?(student, school_class)
    visible_to_students && (:visible == get_visibility_status_for(student, school_class))
  end

  def get_visibility_status_for(student, school_class)
    if (unlock = find_unlock_for(student, school_class)).nil?
      :locked
    else
      unlock.hidden ? false : :visible
    end
  end


  def save_children_versions!(paper_trail_event, recursive)
    child_versions = []
    assessment_questions.each do |child|
      child_versions.append(child.save_current_version_helper!(paper_trail_event, recursive))
    end
    child_versions.map { |x| {type: :question, version_id: x.id} }.to_json
  end

  def restore_children_helper!(child_versions, duplicate)
    child_versions = child_versions.select { |x| x[:type] == 'question' }
    child_version_ids = child_versions.map { |x| x[:version_id] }
    child_versions = PaperTrail::Version.where(item_type: 'AssessmentQuestion', id: child_version_ids)
    unless child_versions.count == child_version_ids.count
      raise ActiveRecord::Rollback.new 'Number of child versions found does not match number saved!'
    end

    if duplicate
      child_versions.each do |x|
        self.class.restore_version_helper(x, duplicate, self)
      end
    else
      to_be_restored_question_ids = child_versions.pluck(:item_id)
      questions_added = assessment_questions.where.not(id: to_be_restored_question_ids)
      questions_added.each { |x| x.destroy! }

      child_versions.each do |x|
        self.class.restore_version_helper(x, duplicate)
      end
    end
  end

end