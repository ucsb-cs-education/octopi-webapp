class CreateLaplayaAnalysisFiles < ActiveRecord::Migration
  def change
    create_table :laplaya_analysis_files do |t|
      t.binary :data
      t.references :task

      t.timestamps
    end
  end
end
