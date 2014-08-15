require 'extensions/ckeditor/ckeditor_base_extension'
module Ckeditor::PicturesControllerExtension
  extend Ckeditor::BaseExtension

  def index
    @pictures = Ckeditor.picture_adapter.find_all(ckeditor_pictures_scope resource_params).accessible_by(current_ability)
    @pictures = Ckeditor::Paginatable.new(@pictures).page(params[:page])

    respond_with(@pictures, :layout => @pictures.first_page?)
  end

  def create
    @picture = Ckeditor.picture_model.new resource_params
    respond_with_asset(@picture)
  end



end