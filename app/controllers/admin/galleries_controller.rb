class Admin::GalleriesController < AdminController
  before_action :set_gallery, only: [:show, :edit, :update, :destroy]
  before_action :set_users, only: [:edit, :update]

  def index
    authorize! :read, Gallery.new
    @galleries = Gallery.all
  end

  def show
    authorize! :read, @gallery
  end

  def new
    authorize! :create, @gallery
    @gallery = Gallery.new(user: current_user)
    set_users
  end

  def edit
    authorize! :edit, @gallery
  end

  def create
    @gallery = Gallery.new(gallery_params)
    @gallery.user = current_user if @gallery.user.nil?
    authorize! :create, @gallery

    if @gallery.save
      redirect_to admin_gallery_path(@gallery), notice: 'Galerie crée avec succès.'
    else
      render :new
    end
  end

  def update
    authorize! :update, @gallery
    if @gallery.update(gallery_params)
      redirect_to admin_gallery_path(@gallery), notice: 'Galerie mise à jour avec succès.'
    else
      render :edit
    end
  end

  def destroy
    authorize! :delete, @gallery
    @gallery.destroy
    redirect_to admin_galleries_path, notice: 'Galerie supprimée avec succès.'
  end

  private
    def set_gallery
      @gallery = Gallery.find(params[:id])
      authorize! :read, @gallery
    end

    def set_users
      @users = User.all if current_user.admin?
    end

    def gallery_params
      permitted_params = [:name, :category]
      permitted_params << :user_id if current_user.admin?
      params.require(:gallery).permit(permitted_params)
    end
end
