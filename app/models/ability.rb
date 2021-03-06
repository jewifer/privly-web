class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    
    #owner can do anything to their post
    can :manage, Post, :user_id => user.id
    can :manage, EmailShare, :post => {:user_id => user.id}
    
    #if it is marked public
    can :show, Post, :public => true
    
    #email shares
    can :manage, EmailShare, :post => {:email_shares => {:email => user.email, :can_share => true}}
    
    can :show, Post, ["EXISTS (SELECT * FROM email_shares WHERE post_id = posts.id AND email = ? AND can_show = true)", user.email] do |post|
      EmailShare.find_by_can_show_and_post_id_and_email(true, post.id, user.email)
    end
    
    can :destroy, Post, ["EXISTS (SELECT * FROM email_shares WHERE post_id = posts.id AND email = ? AND can_destroy = true)", user.email] do |post|
      EmailShare.find_by_can_destroy_and_post_id_and_email(true, post.id, user.email)
    end
    
    can :update, Post, ["EXISTS (SELECT * FROM email_shares WHERE post_id = posts.id AND email = ? AND can_update = true)", user.email] do |post|
      EmailShare.find_by_can_update_and_post_id_and_email(true, post.id, user.email)
    end
    
    can :share, Post, ["EXISTS (SELECT * FROM email_shares WHERE post_id = posts.id AND email = ? AND can_share = true)", user.email] do |post|
      EmailShare.find_by_can_share_and_post_id_and_email(true, post.id, user.email)
    end
    
  end
end
