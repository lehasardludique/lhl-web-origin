class Admin::InfoMessagesController < AdminController
  before_action :set_info_message, only: [:show, :edit, :update, :destroy]

  def index
    authorize! :list, InfoMessage.new
    @info_messages = InfoMessage.all
  end

  def show
    authorize! :read, @info_message
  end

  def new
    @info_message = InfoMessage.new
    authorize! :create, @info_message
    Time.zone = "Paris"
    @info_message.start_at = Time.zone.now.at_beginning_of_day + 3.days
    @info_message.end_at = Time.zone.now.at_end_of_day + 5.days
  end

  def edit
    authorize! :edit, @info_message
  end

  def create
    @info_message = InfoMessage.new(info_message_params)
    authorize! :create, @info_message

    if @info_message.save
      redirect_to admin_info_message_path(@info_message), notice: 'Message créé avec succès.'
    else
      render :new
    end
  end

  def update
    authorize! :update, @info_message
    if @info_message.update(info_message_params)
      redirect_to admin_info_message_path(@info_message), notice: 'Message mis à jour avec succès.'
    else
      render :edit
    end
  end

  def destroy
    authorize! :delete, @info_message
    @info_message.destroy
    redirect_to admin_info_messages_path, notice: 'Message supprimé avec succès.'
  end

  private
    def set_info_message
      @info_message = InfoMessage.find(params[:id])
      authorize! :read, @info_message
    end

    def info_message_params
      permitted_params = [:title, :start_at, :end_at, :modal, :opening, :modal_content, :opening_content, :status]
      params.require(:info_message).permit(permitted_params)
    end
end
