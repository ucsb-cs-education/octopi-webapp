class AddTaskCompletedFilesToLaplayaTasks < ActiveRecord::Migration
  def up
    #Find all the module pages where there doesn't exist a ProjectBaseLaplayaFile with it's parent ID set to the module
    laplaya_file_type = 'TaskCompletedLaplayaFile'
    pages_without_project = LaplayaTask.joins("LEFT OUTER JOIN laplaya_files ON laplaya_files.parent_id = tasks.id AND laplaya_files.type = '#{laplaya_file_type}'").where("laplaya_files.parent_id IS null")

    pages_without_project.each do |page|
      page.create_task_completed_laplaya_file(file_name: 'New Project')
    end
  end
end
