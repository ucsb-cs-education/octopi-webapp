require 'laplaya_module'

class Staff::StaticPagesController < ApplicationController
  before_action :authenticate_staff!
  before_action :setup_laplaya, only: [:laplaya, :laplaya_file]
  before_action :force_trailing_slash, only: [:laplaya]
  before_action :force_no_trailing_slash, only: [:laplaya_file]
  include LaplayaModule

  def laplaya
    laplaya_helper
  end

  def laplaya_file
    @laplaya_ide_params[:fileID] = params[:id]
    laplaya_helper
  end

  def home

  end
end
