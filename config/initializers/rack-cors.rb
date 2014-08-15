# Rails.application.config.middleware.insert_before ActionDispatch::Static, Rack::Cors do
#   allow do
#     origins '*'
#     resource '/public/*', :headers => :any, :methods => :get
#   end
# end