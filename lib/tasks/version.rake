namespace :db do
  desc 'Print current database migration version to the console'
  task version: :environment do
    puts "VERSION=#{ActiveRecord::Migrator.current_version}"
  end
end