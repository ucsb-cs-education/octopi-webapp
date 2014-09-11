# app/services/renderer.rb
# Render views and partials in rake tasks,
# background workers, service objects and more
#
# Use:
#
# class MyService
#   def render_stuff
#     result = renderer.render(partial: 'tweets/tweet', locals: {tweet: Tweet.first})
#     # or even
#     result = renderer.render(Tweet.first)
#   end
#
#   private
#
#   def renderer
#     @renderer ||= Renderer.new.renderer
#   end
# end
#
class Renderer
  def renderer
    controller = ApplicationController.new
    controller.request = ActionDispatch::TestRequest.new
    ViewRenderer.new(Rails.root.join('app', 'views'), {}, controller)
  end
end

# app/services/view_renderer.rb
# A helper class for Renderer
class ViewRenderer < ActionView::Base
  include Rails.application.routes.url_helpers
  include ApplicationHelper

  def default_url_options
    {host: Rails.application.routes.default_url_options[:host]}
  end
end