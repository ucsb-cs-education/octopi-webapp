class Pages::PagesController < ApplicationController
  before_action :authenticate_staff!
  before_action :set_preview, only: :show
  js 'Pages/Pages'

  protected
  def can_update_page?
    (!@preview) && can?(:update, @page)
  end

  private
  def set_preview
    if params[:preview]
      @preview = true
    end
  end

end
