require 'extensions/ckeditor/ckeditor_base_extension'
module Ckeditor::AttachmentFilesControllerExtension
  extend Ckeditor::BaseExtension

  def index
    @attachments = Ckeditor.attachment_file_adapter.find_all(ckeditor_attachment_files_scope resource_params).
        accessible_by(current_ability)
    @attachments = Ckeditor::Paginatable.new(@attachments).page(params[:page])

    respond_with(@attachments, :layout => @attachments.first_page?)
  end

  def create
    @attachment = Ckeditor.attachment_file_model.new resource_params
    respond_with_asset(@attachment)
  end

end