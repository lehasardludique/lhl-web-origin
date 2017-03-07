class Admin::ResourcesController < AdminController
  before_action :set_resource, only: [:show, :edit, :update, :destroy]
  before_action :set_users, only: [:edit, :update]

  def index
    authorize! :read, Resource.new
    @resources = Resource.all
  end

  def show
    authorize! :read, @resource
  end

  def new
    @resource = Resource.new(user: current_user)
    authorize! :create, @resource
    set_users
  end

  def edit
    authorize! :edit, @resource
  end

  def create
    @resource = Resource.new(resource_params)
    @resource.user = current_user if @resource.user.nil?
    authorize! :create, @resource

    if @resource.save
      redirect_to admin_resource_path(@resource), notice: 'Fichier uploadé avec succès.'
    else
      render :new
    end
  end

  def update
    authorize! :update, @resource
    if @resource.update(resource_params)
      redirect_to admin_resource_path(@resource), notice: 'Fichier mis à jour avec succès.'
    else
      render :edit
    end
  end

  def destroy
    authorize! :delete, @resource
    @resource.destroy
    redirect_to admin_resources_path, notice: 'Fichier supprimé avec succès.'
  end

  private
    def set_resource
      @resource = Resource.find(params[:id])
      authorize! :read, @resource
    end

    def set_users
      @users = User.all if current_user.admin?
    end

    def resource_params
      permitted_params = [:name, :notes, :category, :handle]
      permitted_params << :user_id if current_user.admin?
      params.require(:resource).permit(permitted_params)
    end
end
