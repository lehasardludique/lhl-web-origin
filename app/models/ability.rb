class Ability
  include CanCan::Ability

  def initialize(user)

    ## ADMIN

    if user.admin?
      can :manage, :all

    else

    ## ARTICLE
      can [:read], Article do |article|
        article.published? or article.user == user
      end
      can [:create, :update, :delete], Article do |article|
        article.user == user
      end

    ## ARTIST
      can [:read], Artist do |artist|
        artist.published? or artist.user == user
      end
      can [:create, :update, :delete], Artist do |artist|
        artist.user == user
      end

    ## EVENT
      can [:read], Event do |event|
        event.published? or event.user == user
      end
      can [:create, :update, :delete], Event do |event|
        event.user == user
      end

    ## FESTIVAL
      can [:read], Festival do |festival|
        festival.published? or festival.user == user
      end
      can [:create, :update, :delete], Festival do |festival|
        festival.user == user
      end

    ## FOCUS
      can [:read], Focus unless user.new_record?

    ## GALLERY
      can [:read], Gallery unless user.new_record?
      can [:create, :update, :delete], Gallery do |gallery|
        resource.user == user
      end

    ## HOMECAROUSELLINK
      can [:read], HomeCarouselLink unless user.new_record?

    ## PAGE
      can [:read], Page do |page|
        page.published? or page.user == user
      end
      can [:create, :update, :delete], Page do |page|
        page.user == user
      end

    ## PARTNER
      can [:read], Partner unless user.new_record?
      can [:create, :update, :delete], Partner do |partner|
        partner.user == user
      end

    ## RESOURCE
      can [:read], Resource unless user.new_record?
      can [:create, :update, :delete], Resource do |resource|
        resource.user == user
      end

    ## USER
      can [:read, :update, :update_password], User do |edited_user|
        edited_user == user
      end

    end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
