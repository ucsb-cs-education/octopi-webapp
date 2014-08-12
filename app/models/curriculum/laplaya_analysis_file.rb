class LaplayaAnalysisFile < ActiveRecord::Base
  belongs_to :laplaya_task, foreign_key: :task_id
  has_paper_trail :on=> [:update, :destroy]
  include Versionate
end
