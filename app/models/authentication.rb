class Authentication < ActiveRecord::Base

  validates_presence_of :provider, :uid

  belongs_to :user

  def self.authenticate_or_create auth, current_user
    user = Authentication.where(auth.slice('provider', 'uid')).first.try(:user) || create_user_with_authentication(auth, current_user)
  
    if !user.avatar? && auth['info']['image']
      user.remote_avatar_url = auth['info']['image']
      user.save!   
    end
    user
  end

  def self.create_user_with_authentication auth, current_user
    user = current_user ||
      User.create( :email => auth['info']['email'], :name => auth['info']['name'] )

    if user.incognito?
      user.email = auth['info']['email']
      user.name = auth['info']['name']
      user.save
    end

    user.authentications.create do |authentication|
      authentication.provider = auth['provider']
      authentication.uid = auth['uid']
    end


    user
  end

end
