class Admin::EventsController < AdminController
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  before_action :set_users, only: [:edit, :update]

  def index
    authorize! :read, Event.new
    @events = Event.all
  end

  def show
    authorize! :read, @event
  end

  def new
    @event = Event.new(user: current_user)
    authorize! :create, @event
    set_users
  end

  def edit
    authorize! :edit, @event
  end

  def create
    @event = Event.new(event_params)
    @event.user = current_user if @event.user.nil?
    authorize! :create, @event

    if @event.save
      redirect_to admin_event_path(@event), notice: 'Évènement créé avec succès.'
    else
      render :new
    end
  end

  def update
    authorize! :update, @event
    if @event.update(event_params)
      redirect_to admin_event_path(@event), notice: 'Évènement mis à jour avec succès.'
    else
      render :edit
    end
  end

  def destroy
    authorize! :delete, @event
    @event.destroy
    redirect_to admin_events_path, notice: 'Évènement supprimé avec succès.'
  end

  private
    def set_event
      @event = Event.find(params[:id])
      authorize! :read, @event
    end

    def set_users
      @users = User.all if current_user.admin?
    end

    def event_params
      permitted_params = [:focus_id, :category, :weez_event_id, :display_date, :start_time, :end_time, :main_gallery_id, :resource_id, :topic, :title, :subtitle, :content, :final_gallery_id, :exergue, :aside_link_1_data, :aside_link_2_data, :event_link_data, :info_link_data, :social_block, :title_slug, :published_at, :status, :retargeting_pixel_id]
      permitted_params << :user_id if current_user.admin?
      params.require(:event).permit(permitted_params)
    end
end
