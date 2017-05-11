class Admin::EventsController < AdminController
  before_action :is_it_worshop?
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  before_action :set_users, only: [:edit, :update]

  def index
    authorize! :read, Event.new
    @events = @workshop ? Event.workshop : Event.all
  end

  def show
    authorize! :read, @event
  end

  def new
    scope = @workshop ? Event.workshop : Event
    @event = scope.new(user: current_user)
    if params[:weez_event].present? and params[:weez_event].to_i > 0
      weez_event = WeezEvent.find params[:weez_event]
      @event.exchange_data weez_event
    end
    authorize! :create, @event
    set_users
  end

  def edit
    authorize! :edit, @event
  end

  def create
    scope = @workshop ? Event.workshop : Event
    @event = scope.new(event_params)
    @event.user = current_user if @event.user.nil?
    authorize! :create, @event

    if @event.save
      redirect_to admin_event_path(@event), notice: "#{@workshop ? 'Atelier' : 'Évènement'} créé avec succès."
    else
      render :new
    end
  end

  def update
    authorize! :update, @event
    if @event.update(event_params)
      redirect_to admin_event_path(@event), notice: "#{@workshop ? 'Atelier' : 'Évènement'} mis à jour avec succès."
    else
      render :edit
    end
  end

  def destroy
    authorize! :delete, @event
    @event.destroy
    redirect_to admin_events_path, notice: "#{@workshop ? 'Atelier' : 'Évènement'} supprimé avec succès."
  end

  private
    def is_it_worshop?
      @workshop = !!params[:workshop]
    end

    def set_event
      scope = @workshop ? Event.workshop : Event
      @event = scope.find(params[:id])
      authorize! :read, @event
    end

    def set_users
      @users = User.all if current_user.admin?
    end

    def event_params
      permitted_params = [:focus_id, :category, :weez_event_id, :display_date, :start_time, :end_time, :place, :main_gallery_id, :resource_id, :topic, :title, :subtitle, :content, :final_gallery_id, :exergue, :aside_link_1_data, :aside_link_2_data, :event_link_data, :info_link_data, :social_block, :title_slug, :published_at, :status, :retargeting_pixel_id, :workshop_rank, { :new_artist_ids => [] }, { :new_partner_ids => [] }]
      permitted_params << :user_id if current_user.admin?
      params.require(:event).permit(permitted_params)
    end
end
