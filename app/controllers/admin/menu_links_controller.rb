class Admin::MenuLinksController < AdminController
  before_action :set_menu_link, only: [:show, :edit, :update, :destroy]

  def index
    authorize! :list, MenuLink.new
    @menu_links = MenuLink.all
  end

  def show
    authorize! :read, @menu_link
  end

  def new
    @menu_link = MenuLink.new
    authorize! :create, @menu_link
  end

  def edit
    authorize! :edit, @menu_link
  end

  def create
    @menu_link = MenuLink.new(menu_link_params)
    authorize! :create, @menu_link

    if @menu_link.save
      redirect_to admin_menu_link_path(@menu_link), notice: 'Lien créé avec succès.'
    else
      render :new
    end
  end

  def update
    authorize! :update, @menu_link
    if @menu_link.update(menu_link_params)
      redirect_to admin_menu_link_path(@menu_link), notice: 'Lien mis à jour avec succès.'
    else
      render :edit
    end
  end

  def destroy
    authorize! :delete, @menu_link
    @menu_link.destroy
    redirect_to admin_menu_links_path, notice: 'Lien supprimé avec succès.'
  end

  private
    def set_menu_link
      @menu_link = MenuLink.find(params[:id])
      authorize! :read, @menu_link
    end

    def menu_link_params
      permitted_params = [:title, :link_content, :rank, :place, :status]
      params.require(:menu_link).permit(permitted_params)
    end
end
