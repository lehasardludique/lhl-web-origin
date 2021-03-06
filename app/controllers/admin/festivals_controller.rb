class Admin::FestivalsController < AdminController
  before_action :set_festival, only: [:show, :edit, :update, :destroy]
  before_action :set_users, only: [:edit, :update]
  before_action :set_event_list, only: [:edit]

  def index
    authorize! :list, Festival.new
    @festivals = Festival.all
  end

  def show
    authorize! :read, @festival
  end

  def new
    @festival = Festival.new(user: current_user)
    authorize! :create, @festival
    set_event_list
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
      set_event_list
      render :new
    end
  end

  def update
    authorize! :update, @festival
    if @festival.update(festival_params)
      redirect_to admin_festival_path(@festival), notice: 'Festival mis à jour avec succès.'
    else
      set_event_list
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

    def set_event_list
      @events_list = (@festival.events + Event.where('start_time > ?', Time.now.midnight - 1.month)).uniq
      @workshops_list = (@festival.events.workshop + Event.workshop.where('end_time > ?', Time.now.midnight - 1.month)).uniq
    end

    def set_users
      @users = User.all if current_user.admin?
    end

    def festival_params
      permitted_params = [:main_gallery_id, :resource_id, :weez_event_id, :topic, :title, :subtitle, :content, :final_gallery_id, :exergue, :aside_link_1_data, :aside_link_2_data, :event_link_data, :info_link_data, :social_block, :slug, :status, :retargeting_pixel_id, {:new_event_ids => []}, {:new_workshop_ids => []}, {:new_partner_ids => []}]
      permitted_params << :user_id if current_user.admin?
      params.require(:festival).permit(permitted_params)
    end
end
