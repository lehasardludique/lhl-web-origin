class Admin::FocusController < AdminController
  before_action :set_focus, only: [:show, :edit, :update, :destroy]

  def index
    authorize! :list, Focus.new
    @focuses = Focus.all
  end

  def show
    authorize! :read, @focus
  end

  def new
    @focus = Focus.new
    authorize! :create, @focus
  end

  def edit
    authorize! :edit, @focus
  end

  def create
    @focus = Focus.new(focus_params)
    authorize! :create, @focus

    if @focus.save
      redirect_to admin_focus_path(@focus), notice: 'Focus créé avec succès.'
    else
      render :new
    end
  end

  def update
    authorize! :update, @focus
    if @focus.update(focus_params)
      redirect_to admin_focus_path(@focus), notice: 'Focus mis à jour avec succès.'
    else
      render :edit
    end
  end

  def destroy
    authorize! :delete, @focus
    @focus.destroy
    redirect_to admin_focus_path, notice: 'Focus supprimé avec succès.'
  end

  private
    def set_focus
      @focus = Focus.find(params[:id])
      authorize! :read, @focus
    end

    def focus_params
      permitted_params = [:title, :start, :end, :article_id, :status]
      params.require(:focus).permit(permitted_params)
    end
end
