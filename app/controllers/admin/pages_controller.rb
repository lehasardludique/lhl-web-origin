class Admin::PagesController < AdminController
  before_action :set_page, only: [:show, :edit, :update, :destroy]
  before_action :set_users, only: [:edit, :update]

  def index
    authorize! :read, Page.new
    @pages = Page.all
  end

  def show
    authorize! :read, @page
  end

  def new
    @page = Page.new(user: current_user)
    authorize! :create, @page
    set_users
  end

  def edit
    authorize! :edit, @page
  end

  def create
    @page = Page.new(page_params)
    @page.user = current_user if @page.user.nil?
    authorize! :create, @page

    if @page.save
      redirect_to admin_page_path(@page), notice: 'Page créée avec succès.'
    else
      render :new
    end
  end

  def update
    authorize! :update, @page
    if @page.update(page_params)
      redirect_to admin_page_path(@page), notice: 'Page mise à jour avec succès.'
    else
      render :edit
    end
  end

  def destroy
    authorize! :delete, @page
    @page.destroy
    redirect_to admin_pages_path, notice: 'Page supprimée avec succès.'
  end

  private
    def set_page
      @page = Page.find(params[:id])
      authorize! :read, @page
    end

    def set_users
      @users = User.all if current_user.admin?
    end

    def page_params
      permitted_params = [:main_gallery_id, :resource_id, :title, :subtitle, :content, :final_gallery_id, :exergue, :social_block, :slug, :status]
      permitted_params << :user_id if current_user.admin?
      params.require(:page).permit(permitted_params)
    end
end
