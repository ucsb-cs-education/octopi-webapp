require 'laplaya_module'

class Staff::StaticPagesController < ApplicationController
  before_action :authenticate_staff!
  before_action :setup_laplaya, only: [:laplaya, :laplaya_file]
  before_action :set_developer_mode, only: [:laplaya, :laplaya_file]
  before_action :force_trailing_slash, only: [:laplaya]
  before_action :force_no_trailing_slash, only: [:laplaya_file]
  include LaplayaModule

  def laplaya
    staff_laplaya_helper
  end

  def laplaya_file
    authorize! :show, LaplayaFile.select(:id,:type).find(params[:id])
    @laplaya_ide_params[:fileID] = params[:id]
    staff_laplaya_helper
  end

  def home
  end

  def continue_session
    flash[:info] = 'You were already signed in. Welcome back!'
    redirect_to controller: controller_name, action: :home
  end

  private
  def staff_laplaya_helper
    if params[:debug] === 'true'
      if (laplaya_params = params[:laplaya]).is_a? Hash
        laplaya_params.each do |k, v|
          if ((number = Integer(v)) rescue false)
            laplaya_params[k] = number
          elsif v === 'true'
            laplaya_params[k] = true
          elsif v === 'false'
            laplaya_params[k] = false
          end
        end
        @laplaya_ide_params.merge!(laplaya_params)
      end
      render 'laplaya_debug', layout: false
    else
      laplaya_helper
    end
  end

end
