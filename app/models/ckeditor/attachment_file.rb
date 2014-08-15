class Ckeditor::AttachmentFile < Ckeditor::Asset
  has_attached_file :data

  validates_attachment_presence :data
  validates_attachment_size :data, :less_than => 100.megabytes
  #we should define what we allow our admins to upload...
  # validates_attachment_content_type :data, content_type: ['application/pdf']
  do_not_validate_attachment_file_type :data

  def url_thumb
    @url_thumb ||= Ckeditor::Utils.filethumb(filename)
  end
end
