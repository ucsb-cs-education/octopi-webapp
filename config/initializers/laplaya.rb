# if defined?(AssetSync) && AssetSync.config.run_on_precompile
#
#   asset_path = Rails.root.join('lib', 'assets', 'javascripts')
#   files = []
#   %w(lang-*.js *.gif *.png
# help/*.png
# Sounds/*.mp3 Sounds/*.wav Sounds/index.html
# Costumes/*.gif Costumes/*.png Costumes/index.html
# Backgrounds/*.jpg Backgrounds/*.gif Backgrounds/index.html
# ).each do |path|
#     files += Dir[asset_path.join('laplaya', path)].map { |x| x.sub(asset_path.to_path, '').sub(/^\/+/, '') }
#   end
#   Rails.application.config.assets.precompile += files
# end
