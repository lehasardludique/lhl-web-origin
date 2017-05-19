class Admin::ArtistsController < AdminController
  before_action :set_artist, only: [:show, :edit, :update, :destroy]
  before_action :set_users, only: [:edit, :update]

  def index
    authorize! :list, Artist.new
    @artists = Artist.all
  end

  def show
    authorize! :read, @artist
  end

  def new
    @artist = Artist.new(user: current_user)
    authorize! :create, @artist
    set_users
  end

  def edit
    authorize! :edit, @artist
  end

  def create
    @artist = Artist.new(artist_params)
    @artist.user = current_user if @artist.user.nil?
    authorize! :create, @artist

    if @artist.save
      redirect_to admin_artist_path(@artist), notice: 'Artiste créé avec succès.'
    else
      render :new
    end
  end

  def update
    authorize! :update, @artist
    if @artist.update(artist_params)
      redirect_to admin_artist_path(@artist), notice: 'Artiste mis à jour avec succès.'
    else
      render :edit
    end
  end

  def destroy
    authorize! :delete, @artist
    @artist.destroy
    redirect_to admin_artists_path, notice: 'Artiste supprimé avec succès.'
  end

  private
    def set_artist
      @artist = Artist.find(params[:id])
      authorize! :read, @artist
    end

    def set_users
      @users = User.all if current_user.admin?
    end

    def artist_params
      permitted_params = [:name, :resource_id, :content, :media_link_fbk, :media_link_twt, :media_link_isg, :media_link_msk, :media_link_vid, :media_link_www, :status]
      permitted_params << :user_id if current_user.admin?
      params.require(:artist).permit(permitted_params)
    end
end
