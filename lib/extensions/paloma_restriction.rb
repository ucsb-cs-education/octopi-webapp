module PalomaRestriction
  extend ActiveSupport::Concern
  included do
    before_action :set_paloma
  end

  def set_paloma
    js false
  end
end
