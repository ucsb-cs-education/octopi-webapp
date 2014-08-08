class StaticPagesController < ApplicationController
  def home
    #TODO: Do we want this? I thought it might be good to auto redirect to student login..
    # if not staff_signed_in?
    #   redirect_to student_portal_root_path
    # end
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
