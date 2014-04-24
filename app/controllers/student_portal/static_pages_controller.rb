class StudentPortal::StaticPagesController < StudentPortal::BaseController
  before_filter :force_trailing_slash, only: 'snap'


  before_action :signed_in_student, only: [:home]

  def home
    $stderr.puts "XXXXXXXXX#{current_user}XXXXXXX"

  end

  def help
  end

  def snap
    render :layout => false
  end

  private
    def force_trailing_slash
      redirect_to request.original_url + '/' unless request.original_url.match(/\/$/)
    end
end
