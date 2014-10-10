class BaseLaplayaFile < LaplayaFile
  include Curriculumify
  include Versionate
  undef :visible_to
  undef :visible_to=
  after_save :update_parent_updated_time

  private
  def update_parent_updated_time
    parent.update_attributes!(updated_at: updated_at)
  end

end