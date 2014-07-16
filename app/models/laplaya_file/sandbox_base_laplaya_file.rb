class SandboxBaseLaplayaFile < ModuleBaseLaplayaFile
  validates :parent_id, uniqueness: true, allow_nil: false

end