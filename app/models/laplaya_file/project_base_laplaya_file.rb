class ProjectBaseLaplayaFile < ModuleBaseLaplayaFile
  validates :parent_id, uniqueness: true, allow_nil: false

end