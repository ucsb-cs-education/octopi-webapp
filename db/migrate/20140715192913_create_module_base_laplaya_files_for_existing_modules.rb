class CreateModuleBaseLaplayaFilesForExistingModules < ActiveRecord::Migration
  def up
    #Find all the module pages where there doesn't exist a ProjectBaseLaplayaFile with it's parent ID set to the module
    laplaya_file_type = 'ProjectBaseLaplayaFile'
    pages_without_project = ModulePage.joins("LEFT OUTER JOIN laplaya_files ON laplaya_files.parent_id = pages.id AND laplaya_files.type = '#{laplaya_file_type}'").where("laplaya_files.parent_id IS null")

    pages_without_project.each do |page|
      ProjectBaseLaplayaFile.new_base_file(page)
    end

    #Find all the module pages where there doesn't exist a SandboxBaseLaplayaFile with it's parent ID set to the module
    laplaya_file_type = 'SandboxBaseLaplayaFile'
    pages_without_sandbox = ModulePage.joins("LEFT OUTER JOIN laplaya_files ON laplaya_files.parent_id = pages.id AND laplaya_files.type = '#{laplaya_file_type}'").where("laplaya_files.parent_id IS null")

    pages_without_sandbox.each do |page|
      SandboxBaseLaplayaFile.new_base_file(page)
    end

  end
end
