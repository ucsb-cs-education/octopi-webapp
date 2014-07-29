namespace :laplaya do
  desc 'Copy static laplaya assets to the public directory'
  task :copy_static_assets do
    asset_path = 'lib/assets/javascripts/laplaya/'
    asset_regex = /lib\/assets\/javascripts\/laplaya\//
    dest_path = 'public/static/laplaya/'
    files = %w(lang-*.js *.gif *.png
help/*.png
Sounds/*.mp3 Sounds/*.wav Sounds/index.html
Costumes/*.gif Costumes/*.png Costumes/index.html
Backgrounds/*.jpg Backgrounds/*.gif Backgrounds/index.html
).map{|x| asset_path+x}
    for file in Dir.glob(files,0)
      dest = file.sub asset_regex, dest_path
      dirname = File.dirname dest
      unless File.directory? dirname
        FileUtils.mkdir_p dirname, verbose: true
      end
      FileUtils.cp file, dest, verbose: true
    end
  end
end

# auto run ckeditor:create_nondigest_assets after assets:precompile
Rake::Task['assets:precompile'].enhance do
  Rake::Task['laplaya:copy_static_assets'].invoke
end