module LaplayaModule
  extend ActiveSupport::Concern

  def laplaya_helper
    render 'laplaya', layout: false
  end

  def set_developer_mode
    if staff_signed_in? && Ability.new(current_staff).can?(:see_developer_view, LaplayaFile)
      @laplaya_ide_params['developerMode'] = true
    end
  end

  #Should be called before all laplaya based actions
  def setup_laplaya
    js false
    @laplaya_ide_params = {}
    @laplaya_ide_params['root_path'] = '/static/laplaya/'
  end

  #Should be used whenever we are loading a specific file
  def force_no_trailing_slash
    force_slash :noslash
  end

  #Should be used whenever we are loading an empty sandbox
  def force_trailing_slash
    force_slash :slash
  end

  def force_slash(slash = :slash)
    if slash == :slash
      redirect_to request.original_url + '/' unless request.original_url.match(/\/$/)
    elsif slash == :noslash
      redirect_to request.original_url.gsub /\/+$/, '' unless request.original_url.match(/[^\/]$/)
    end
  end

end