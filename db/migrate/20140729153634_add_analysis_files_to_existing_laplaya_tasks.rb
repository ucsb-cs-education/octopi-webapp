class AddAnalysisFilesToExistingLaplayaTasks < ActiveRecord::Migration
  def change
    LaplayaTask.includes(:laplaya_analysis_file).
        references(:laplaya_analysis_files).where(laplaya_analysis_files: {id: nil}).
        find_each(batch_size: 400) do |task|
      if task.laplaya_analysis_file.nil?
        task.create_laplaya_analysis_file
      end
    end
  end
end
