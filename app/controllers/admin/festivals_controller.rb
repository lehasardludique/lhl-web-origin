class Admin::FestivalsController < AdminController
  before_action :set_festival, only: [:show, :edit, :update, :destroy]
  before_action :set_users, only: [:edit, :update]

  def index
    authorize! :read, Festival.new
    @festivals = Festival.all
  end

  def show
    authorize! :read, @festival
  end

  def new
    @festival = Festival.new(user: current_user)
    authorize! :create, @festival
    set_users
  end

  def edit
    authorize! :edit, @festival
  end

  def create
    @festival = Festival.new(festival_params)
    @festival.user = current_user if @festival.user.nil?
    authorize! :create, @festival

    if @festival.save
      redirect_to admin_festival_path(@festival), notice: 'Festival créé avec succès.'
    else
      render :new
    end
  end

  def update
    authorize! :update, @festival
    if @festival.update(festival_params)
      redirect_to admin_festival_path(@festival), notice: 'Festival mis à jour avec succès.'
    else
      render :edit
    end
  end

  def destroy
    authorize! :delete, @festival
    @festival.destroy
    redirect_to admin_festivals_path, notice: 'Festival supprimé avec succès.'
  end

  private
    def set_festival
      @festival = Festival.find(params[:id])
      authorize! :read, @festival
    end

    def set_users
      @users = User.all if current_user.admin?
    end

    def festival_params
      permitted_params = [:main_gallery_id, :resource_id, :title, :subtitle, :content, :final_gallery_id, :exergue, :aside_link_1_data, :aside_link_2_data, :aside_link_3_data, :event_link_data, :info_link_data, :social_block, :slug, :status, :retargeting_pixel_id]
      permitted_params << :user_id if current_user.admin?
      params.require(:festival).permit(permitted_params)
    end
end
