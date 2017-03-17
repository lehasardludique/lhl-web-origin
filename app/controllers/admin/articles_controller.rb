class Admin::ArticlesController < AdminController
  before_action :set_article, only: [:show, :edit, :update, :destroy]
  before_action :set_users, only: [:edit, :update]

  def index
    authorize! :read, Article.new
    @articles = Article.all
  end

  def show
    authorize! :read, @article
  end

  def new
    @article = Article.new(user: current_user)
    authorize! :create, @article
    set_users
  end

  def edit
    authorize! :edit, @article
  end

  def create
    @article = Article.new(article_params)
    @article.user = current_user if @article.user.nil?
    authorize! :create, @article

    if @article.save
      redirect_to admin_article_path(@article), notice: 'Article créée avec succès.'
    else
      render :new
    end
  end

  def update
    authorize! :update, @article
    if @article.update(article_params)
      redirect_to admin_article_path(@article), notice: 'Article mise à jour avec succès.'
    else
      render :edit
    end
  end

  def destroy
    authorize! :delete, @article
    @article.destroy
    redirect_to admin_articles_path, notice: 'Article supprimée avec succès.'
  end

  private
    def set_article
      @article = Article.find(params[:id])
      authorize! :read, @article
    end

    def set_users
      @users = User.all if current_user.admin?
    end

    def article_params
      permitted_params = [:main_gallery_id, :resource_id, :topic, :title, :subtitle, :content, :final_gallery_id, :exergue, :aside_link_1_data, :aside_link_2_data, :aside_link_3_data, :event_link_data, :info_link_data, :social_block, :title_slug, :published_at, :status, :media_link_fbk, :media_link_twt, :media_link_isg, :media_link_msk, :media_link_vid, :media_link_www]
      permitted_params << :user_id if current_user.admin?
      params.require(:article).permit(permitted_params)
    end
end
