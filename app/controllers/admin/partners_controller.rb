class Admin::PartnersController < AdminController
  before_action :set_partner, only: [:show, :edit, :update, :destroy]
  before_action :set_users, only: [:edit, :update]

  def index
    authorize! :read, Partner.new
    @partners = Partner.all
  end

  def show
    authorize! :read, @partner
  end

  def new
    @partner = Partner.new(user: current_user)
    authorize! :create, @partner
    set_users
  end

  def edit
    authorize! :edit, @partner
  end

  def create
    @partner = Partner.new(partner_params)
    @partner.user = current_user if @partner.user.nil?
    authorize! :create, @partner

    if @partner.save
      redirect_to admin_partner_path(@partner), notice: 'Partenaire créé avec succès.'
    else
      render :new
    end
  end

  def update
    authorize! :update, @partner
    if @partner.update(partner_params)
      redirect_to admin_partner_path(@partner), notice: 'Partenaire mis à jour avec succès.'
    else
      render :edit
    end
  end

  def destroy
    authorize! :delete, @partner
    @partner.destroy
    redirect_to admin_partners_path, notice: 'Partenaire supprimé avec succès.'
  end

  private
    def set_partner
      @partner = Partner.find(params[:id])
      authorize! :read, @partner
    end

    def set_users
      @users = User.all if current_user.admin?
    end

    def partner_params
      permitted_params = [:name, :resource_id, :link, :notes, :category]
      permitted_params << :user_id if current_user.admin?
      params.require(:partner).permit(permitted_params)
    end
end
