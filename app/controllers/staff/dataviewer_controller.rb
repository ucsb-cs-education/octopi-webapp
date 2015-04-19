class Staff::DataviewerController < ApplicationController
def dataviewer
  authorize! :show,
  @filterrific = initialize_filterrific(
      LaplayaFile,
      params[:filterrific],
      select_options: {
          sorted_by: LaplayaFile.options_for_sorted_by
      }
  )or return
  @files = @filterrific.find.page(params[:page])
  respond_to do |format|
    format.html
    format.js {render :js => false}
    end
  end
end