class ArticlesController < ApplicationController
  def show
    @article = Article.find_by! date_slug: params[:date], title_slug: params[:slug]
    if
    (not @article.visible? and not logged_in?) or
    (@article.draft? and (not logged_in? or not @article.user == current_user)) or
    (@article.restricted? and not logged_in?)
      not_found!
    end
    meta_title @article.title
    set_meta_og @article
    body_classes 'page'
  end
end