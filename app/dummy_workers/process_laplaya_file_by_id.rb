require 'resque-loner'
class ProcessLaplayaFileById
  include Resque::Plugins::UniqueJob
  @queue = :normal


end