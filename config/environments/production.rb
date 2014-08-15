OctopiWebapp::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both thread web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like nginx, varnish or squid.
  # config.action_dispatch.rack_cache = true

  # Disable Rails's static asset server (Apache or nginx will already do this).
  config.serve_static_assets = true
  config.assets.enabled = true

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Generate digests for assets URLs.
  config.assets.digest = true

  # Version of your assets, change this if you want to expire all your assets.
  config.assets.version = '1.0'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Set to :debug to see everything in the log.
  config.log_level = :info
  config.log_level = ENV["LOG_LEVEL"].to_sym if ENV["LOG_LEVEL"]

  # Prepend all log lines with the following tags.
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups.
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.

  # Precompile additional assets.
  # application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
  # config.assets.precompile += %w( search.js )
  config.assets.precompile += %w( laplaya_application.js )
  config.assets.precompile += %w( active_admin.js )

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Disable automatic flushing of the log to improve performance.
  # config.autoflush_log = false

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new
  config.time_zone = 'Pacific Time (US & Canada)'

  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.default_url_options = {:host => 'octopi.herokuapp.com'}
  ActionMailer::Base.smtp_settings = {
      :address => 'smtp.sendgrid.net',
      :port => '587',
      :authentication => :plain,
      :user_name => ENV['SENDGRID_USERNAME'],
      :password => ENV['SENDGRID_PASSWORD'],
      :domain => 'heroku.com',
      :enable_starttls_auto => true
  }

  config.lograge.enabled = true

  if ENV['USE_CLOUD_FOR_ASSETS'] == 'true'
    config.assets.initialize_on_precompile = true
    config.static_cache_control = 'public, max-age=31536000'
    config.action_controller.asset_host = ENV['CLOUDFRONT_URL']
    if ENV['CLOUDFRONT_DISTRIBUTION_ID']
      config.cdn_distribution_id = ENV['CLOUDFRONT_DISTRIBUTION_ID']
    end
  end

  #Paperclip S3
  s3_proto = ENV['PAPERCLIP_S3_PROTOCOL'] || :http
  paperclip_settings = {
      :storage => :s3,
      :s3_credentials => {
          :bucket => ENV['S3_BUCKET_NAME'],
          :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
          :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
      },
      :s3_protocol => s3_proto
  }

  if ENV['PAPERCLIP_CDN_URL'] && ENV['PAPERCLIP_CDN_URL'].present?
    result = ENV['PAPERCLIP_CDN_URL']
    result = result.split(':id:')
    if result.length == 1
      result = result[0]
    elsif result.length == 2
      start_str = result[0]
      end_str = result[1]
      temp = Proc.new { |attachment| start_str + (attachment.instance.id % 4).to_s + end_str }
      result = temp
    else
      raise 'Paperclip CDN URL must be either a fqdn, or an fqdn with a single occurence of ":id:" to put an id in'
    end
    paperclip_settings[:url] = ':s3_alias_url'
    paperclip_settings[:s3_host_alias] = result
    paperclip_settings[:path] = ':class/:attachment/:id_partition/:style/:filename'
  end


  config.paperclip_defaults = paperclip_settings

  config.auto_cloudify_laplaya_files = ENV['AUTO_CLOUDIFY_LAPLAYA_FILES'] === 'true'
  config.laplaya_root_path = ENV['LAPLAYA_ROOT_PATH'] || '/assets/laplaya/'

end
