class ModuleBaseLaplayaFile < BaseLaplayaFile
  belongs_to :module_page, foreign_key: :parent_id
  alias_attribute :parent, :module_page

end