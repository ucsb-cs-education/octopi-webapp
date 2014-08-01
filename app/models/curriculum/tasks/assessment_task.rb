class AssessmentTask < Task
  has_many :assessment_questions, -> { order('position ASC') }, foreign_key: :assessment_task_id
  alias_attribute :children, :assessment_questions

  def update_with_children(params, ids)
    transaction do
      child_ids = children.pluck(:id).map { |x| x.to_s }
      raise(ArgumentError, 'update_children_order ids must match children ids') unless same_elements?(child_ids, ids)
      if child_ids != ids
        children = {}
        ids.each_with_index.map { |x, i| children[x] = {position: i+1} }
        AssessmentQuestion.update(children.keys, children.values)
      end
      update_attributes!(params)
    end
  end

  def is_accessible?(student, school_class)
    status = get_visibility_status_for(student, school_class)
    status == :visible
  end

  def get_visibility_status_for(student, school_class)
    if (unlock = find_unlock_for(student, school_class)).nil?
      :locked
    else
      unlock.hidden ? false : :visible
    end
  end
end