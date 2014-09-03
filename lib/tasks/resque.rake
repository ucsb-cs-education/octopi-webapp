require "resque/tasks"
require 'resque-delayed/tasks'

task "resque:setup" => :environment

#To run the delay worker
#LOGGING=1 INTERVAL=10 rake resque_delayed:work