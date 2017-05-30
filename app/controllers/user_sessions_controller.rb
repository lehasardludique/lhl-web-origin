class UserSessionsController < ApplicationController
  skip_before_action :authorize if Rails.env.staging?
  skip_before_action :set_modal, :set_opening_time, :set_menu_and_footer, :store_location
  
  def new
    @no_menu = true
    @no_footer = true
    @user = User.new
    meta_title 'Connexion'
    body_classes 'bubble'
  end

  def create
    if @user = login(user_params[:email], user_params[:password], user_params[:remember])
      redirect_back_or_to session_path, notice: 'Bienvenue ! Connexion réussie'
    else
      @no_menu = true
      @no_footer = true
      @user = User.new(email: user_params[:email], password: user_params[:password])
      flash.now[:error] = 'Impossible de se connecter, merci de vérifier vos identifiant et mot de passe.'
      meta_title 'Connexion'
      body_classes 'bubble'
      render action: 'new'
    end
  end

  def destroy
    logout
    redirect_to :root, notice: 'Déconnexion réussie, à bientôt !'
  end

  private
    def user_params
      params.require(:user).permit(:email, :password, :remember)
    end
end
