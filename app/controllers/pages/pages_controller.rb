class Pages::PagesController < ApplicationController
  before_action :authenticate_staff!
  js 'Pages/Pages'

  def save_version
    @page.save_current_version
    redirect_to @page
  end
end
