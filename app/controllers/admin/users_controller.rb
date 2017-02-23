class Admin::UsersController < AdminController
  before_action :set_user, only: [:show, :edit, :update, :password, :password_update, :destroy]

  def index
    authorize! :read, User.new
    @users = User.all
  end

  def show
  end

  def new
    @user = User.new
    authorize! :create, @user
  end

  def edit
    authorize! :edit, @user
  end

  def create
    @user = User.new(user_params)
    authorize! :create, @user

    if @user.save
      redirect_to admin_user_path(@user), notice: 'Utilisateur créé avec succès.'
    else
      render :new
    end
  end

  def update
    authorize! :create, @user
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: 'Utilisateur mis à jour avec succès.'
    else
      render :edit
    end
  end

  def password
    authorize! :update_password, @user
  end

  def password_update
    authorize! :update_password, @user
    @user.form = 'password'
    if @user.update(password_params)
      redirect_to admin_user_path(@user), notice: 'Mot de passe mis à jour avec succès.'
    else
      render :password
    end
  end

  def destroy
    authorize! :delete, @user
    @user.destroy
    redirect_to admin_users_path, notice: 'Utilisateur supprimé avec succès.'
  end

  private
    def set_user
      @user = User.find(params[:id] || params[:user_id])
      authorize! :read, @user
    end

    def user_params
      permitted_params = [:first_name, :last_name, :email, :avatar_id]
      permitted_params += [:status, :role, :master_id] if current_user.admin?
      params.require(:user).permit(permitted_params)
    end

    def password_params
      params.require(:user).permit(:password, :password_confirmation)
    end
end
