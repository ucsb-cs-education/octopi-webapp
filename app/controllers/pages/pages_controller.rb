class Pages::PagesController < ApplicationController
  before_action :authenticate_staff!
  before_action :set_raw, only: :show
  js 'Pages/Pages'

  def save_version
    @page.save_current_version
    redirect_to @page
  end

  private
  def set_raw
    @raw = can?(:update, @page) && params[:raw]
  end
end
