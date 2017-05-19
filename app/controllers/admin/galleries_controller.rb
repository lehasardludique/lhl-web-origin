class Admin::GalleriesController < AdminController
  before_action :set_gallery, only: [:show, :edit, :update, :images, :images_update, :destroy]
  before_action :set_users, only: [:edit, :update]

  def index
    authorize! :list, Gallery.new
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

  def images
    set_gallery_resources
  end

  def images_update
    begin
      if defined? params[:gallery][:resource_new_rank] and params[:gallery][:resource_new_rank].to_i > 0
        image_ship = ImageShip.find params[:gallery][:resource_new_rank]
        new_rank = params[:gallery][:resources][image_ship.id.to_s] if defined? params[:gallery][:resources][image_ship.id.to_s]
        image_ship.update! rank: new_rank if new_rank
        redirect_path = admin_gallery_images_path @gallery
      end
      ImageShip.create!(new_resource_params) if defined? params[:gallery][:new_resource_id] and params[:gallery][:new_resource_id].to_i > 0
      redirect_path ||= (params[:commit] == t('save_and_go')) ? admin_gallery_images_path(@gallery) : admin_gallery_path(@gallery)
      redirect_to redirect_path, notice: 'Galerie mise à jour avec succès.'
    rescue
      flash.now[:error] = "Ooops"
      set_gallery_resources
      render :images
    end
  end

  def images_delete
    is = ImageShip.find params[:id]
    is.delete
    redirect_to admin_gallery_images_path(is.gallery), notice: 'Galerie mise à jour avec succès.'
  end

  def destroy
    authorize! :delete, @gallery
    @gallery.destroy
    redirect_to admin_galleries_path, notice: 'Galerie supprimée avec succès.'
  end

  private
    def set_gallery
      @gallery = Gallery.find(params[:id] || params[:gallery_id])
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

    def new_resource_params
      tmp_params = {}
      tmp_params[:gallery_id] = @gallery.id if @gallery
      tmp_params[:resource_id] = params[:gallery][:new_resource_id] if defined? params[:gallery][:new_resource_id]
      tmp_params[:rank] = params[:gallery][:new_resource_rank] if defined? params[:gallery][:new_resource_rank]
      tmp_params
    end

    def set_gallery_resources
      @gallery.form = 'images'
      galleried_resource_ids = ImageShip.select(:resource_id).reorder(nil).distinct.pluck(:resource_id)
      if params[:scope] == 'in_galleries'
        @new_resources_available = (Resource.gallery.where.not(id: galleried_resource_ids).size > 0)
      else
        @resources = Resource.gallery.where.not(id: galleried_resource_ids)
      end
      if @resources.nil? or @resources.blank?
        @resources = Resource.gallery.where(id: (galleried_resource_ids - @gallery.resource_ids))
      elsif galleried_resource_ids.any?
        @galleried_available = true
      end
      @max_rank = ImageShip.where(gallery_id: @gallery.id).size
      @max_rank = @max_rank.to_i
    end
end
