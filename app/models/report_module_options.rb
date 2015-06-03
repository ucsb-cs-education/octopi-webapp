class ReportModuleOptions < ActiveRecord::Base
  belongs_to :report
  belongs_to :module_page
end
