class PagesController < ApplicationController
  def home
    body_classes 'wip'
  end

  def redirect
    redirect_to "//lafabrique.lehasardludique.paris/#{params[:slug]}", status: :moved_permanently
  end
end