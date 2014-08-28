class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
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
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
    user ||= User.new
    puts user.inspect
    if user.is_active?
        if user.admin?
            puts "is_admin!"
            can :manage, :all
            can :read, :all
        elsif user.base?
            can :manage, App do |app|
                Ownership.where({:app_id => app.id, :user_id => user.id}).any?
            end
            can :create, App
            can :manage, Placement do |placement|
                Ownership.where({:app_id => placement.app_id, :user_id => user.id}).any?
            end
            can :create, Placement
            can :manage, Campaign do |campaign|
                Ownership.where({:app_id => campaign.placement.app.id, :user_id => user.id}).any?
            end
            can :create, Campaign
            can :manage, Asset do |asset|
                Ownership.where({:app_id => asset.campaign.placement.app.id, :user_id => user.id}).any?
            end
            can :create, Asset
        end
    end
    can :modulo, Asset
    can :show, Invite
    can :grant, Invite
  end
end
