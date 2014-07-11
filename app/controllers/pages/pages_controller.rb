class Pages::PagesController < ApplicationController
  before_action :authenticate_staff!
  js 'Pages/Pages'
end
