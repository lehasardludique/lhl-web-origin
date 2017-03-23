class Admin::HomeCarouselLinksController < AdminController
  before_action :set_home_carousel_link, only: [:show, :edit, :update, :destroy]

  def index
    authorize! :read, HomeCarouselLink.new
    @home_carousel_links = HomeCarouselLink.all
  end

  def show
    authorize! :read, @home_carousel_link
  end

  def new
    @home_carousel_links = HomeCarouselLink.all
    @home_carousel_link = HomeCarouselLink.new
    authorize! :create, @home_carousel_link
  end

  def edit
    authorize! :edit, @home_carousel_link
  end

  def create
    @home_carousel_link = HomeCarouselLink.new(home_carousel_link_params)
    authorize! :create, @home_carousel_link

    if @home_carousel_link.save
      redirect_to new_admin_home_carousel_link_path, notice: 'Lien ajouté avec succès.'
    else
      flash.now[:error] = "Impossible d'enregistrer ce lien."
      render :new
    end
  end

  def update
    authorize! :update, @home_carousel_link
    if @home_carousel_link.update(home_carousel_link_params)
      redirect_to admin_home_carousel_link_path(@home_carousel_link), notice: 'Lien mis à jour avec succès.'
    else
      flash.now[:error] = "Impossible de mettre à jour ce lien."
      render :edit
    end
  end

  def destroy
    authorize! :delete, @home_carousel_link
    @home_carousel_link.destroy
    redirect_to new_admin_home_carousel_link_path, notice: 'Lien supprimé avec succès.'
  end

  private
    def set_home_carousel_link
      @home_carousel_link = HomeCarouselLink.find(params[:id])
      authorize! :read, @home_carousel_link
    end

    def home_carousel_link_params
      permitted_params = [:home_linkable_id, :home_linkable_type, :rank, :title, :subtitle, :resource_id, :status]
      params.require(:home_carousel_link).permit(permitted_params)
    end
end