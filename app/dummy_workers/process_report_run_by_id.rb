require 'resque-loner'
class ProcessReportRunById
  include Resque::Plugins::UniqueJob
  @queue = :normal

end
