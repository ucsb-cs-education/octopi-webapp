module Ckeditor::BaseExtension
  extend ActiveSupport::Concern
  included do
    remove_method :index
    remove_method :create
  end

end
