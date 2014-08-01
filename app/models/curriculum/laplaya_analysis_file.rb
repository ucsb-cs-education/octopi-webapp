class LaplayaAnalysisFile < ActiveRecord::Base
  belongs_to :laplaya_task, foreign_key: :task_id
end
