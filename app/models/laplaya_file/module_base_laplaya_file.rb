class ModuleBaseLaplayaFile < BaseLaplayaFile
  belongs_to :module_page, foreign_key: :parent_id
  alias_attribute :parent, :module_page

  def self.new_base_file(module_page)
    return self.create!(file_name: 'New Project', module_page: module_page)
  end

end