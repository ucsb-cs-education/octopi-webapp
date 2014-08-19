require 'digest'
namespace :laplaya do
  desc 'Copy static laplaya source for staff debug mode'
  task :copy_laplaya_source_for_debug do
    asset_dir = Rails.root.join('lib/assets/javascripts/')
    dest_dir = Rails.root.join('public/javascripts', Rails.application.config.laplaya_debug_dest_path)
    files = Rails.application.config.laplaya_debug_sources.map { |x| asset_dir.join(x) }
    for file in files
      dest = file.to_s.sub asset_dir.to_s, dest_dir.to_s
      dirname = File.dirname dest
      unless File.directory? dirname
        FileUtils.mkdir_p dirname, verbose: true
      end
      if !File.exist?(dest) or (Digest::MD5.file(file) != Digest::MD5.file(dest))
        FileUtils.cp file, dest, verbose: true, preserve: true
      end
    end
  end
end

# auto run ckeditor:create_nondigest_assets after assets:precompile
  Rake::Task['assets:precompile'].enhance do
    Rake::Task['laplaya:copy_laplaya_source_for_debug'].invoke
  end
