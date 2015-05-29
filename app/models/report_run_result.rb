class ReportRunResult < ActiveRecord::Base
  belongs_to :report_run
  belongs_to :laplaya_file
end
