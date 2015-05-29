class ReportRun < ActiveRecord::Base
  belongs_to :report
  has_many :report_run_results
end
