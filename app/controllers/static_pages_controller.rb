require 'filterrific'
require 'will_paginate'
class StaticPagesController < ApplicationController
  def home
    #TODO: Do we want this? I thought it might be good to auto redirect to student login..
    # if not staff_signed_in?
    #   redirect_to student_portal_root_path
    # end
  end

  def dataviewer
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
  
  def help
  end

  def contact
    @contact = Contact.new
  end

  def send_contact
    @contact = Contact.new(params[:contact])
    @contact.request = request
    if @contact.deliver
      flash[:notice] = 'Thank you for your message. We will contact you soon!'
      redirect_to :contact
    else
      flash.now[:error] = 'Cannot send message.'
      render :contact
    end
  end
end
