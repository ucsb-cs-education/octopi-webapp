require 'digest'
namespace :laplaya do
  desc 'Copy static laplaya assets to the public directory'
  task :copy_static_assets do
    asset_path = 'lib/assets/javascripts/laplaya/'
    asset_regex = /lib\/assets\/javascripts\/laplaya\//
    dest_path = 'public/assets/laplaya/'
    files_changed = []
    files = %w(lang-*.js *.gif *.png
help/*.png
Sounds/*.mp3 Sounds/*.wav Sounds/index.html
Costumes/*.gif Costumes/*.png Costumes/index.html
Backgrounds/*.jpg Backgrounds/*.gif Backgrounds/index.html
).map { |x| asset_path+x }
    for file in Dir.glob(files, 0)
      base_name = file.sub(asset_regex, 'laplaya/')
      dest = file.sub asset_regex, dest_path
      dirname = File.dirname dest
      unless File.directory? dirname
        FileUtils.mkdir_p dirname, verbose: true
      end
      if !File.exist?(dest) or (Digest::MD5.file(file) != Digest::MD5.file(dest))
        FileUtils.cp file, dest, verbose: true, preserve: true
        files_changed << base_name
      end
    end
    if ENV['USE_CLOUD_FOR_LAPLAYA_SOURCE_ASSETS'] == 'true' && defined?(AssetSync) && AssetSync.config.run_on_precompile
      AssetSync.config.invalidate.push(*files_changed)
    end
  end
end

# auto run ckeditor:create_nondigest_assets after assets:precompile
if ENV['USE_CLOUD_FOR_LAPLAYA_SOURCE_ASSETS'] == 'true' && defined?(AssetSync) && AssetSync.config.run_on_precompile
  Rake::Task['assets:sync'].enhance ['laplaya:copy_static_assets']
else
  Rake::Task['assets:precompile'].enhance do
    Rake::Task['laplaya:copy_static_assets'].invoke
  end
end
