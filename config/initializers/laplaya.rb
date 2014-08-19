Rails.application.config.auto_cloudify_laplaya_files = ENV['AUTO_CLOUDIFY_LAPLAYA_FILES'] === 'true'
Rails.application.config.laplaya_root_path = ENV['LAPLAYA_ROOT_PATH'] || '/assets/laplaya/'
Rails.application.config.laplaya_debug_sources = %w(morphic.js widgets.js blocks.js threads.js objects.js gui.js paint.js
lists.js byob.js xml.js store.js locale.js octopi_cloud.js sha512.js FileSaver.js).map { |x| 'laplaya/'+x }
Rails.application.config.laplaya_debug_dest_path = 'debug_assets/'

