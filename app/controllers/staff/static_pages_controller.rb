class Staff::StaticPagesController < ApplicationController
  before_action :authenticate_staff!
  def home
  end
end
