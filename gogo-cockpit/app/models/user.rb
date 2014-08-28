class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
	devise :database_authenticatable, :registerable,
	:recoverable, :rememberable, :trackable, :validatable, :omniauthable, :confirmable

	has_many :apps

	def self.from_omniauth(auth)
		where(:auth_provider => auth.provider, :auth_uid => auth.uid).first_or_create do |user|
			user.email = auth.info.email
			user.auth_provider = auth.provider
			user.auth_uid = auth.uid
			user.auth_token = Devise.friendly_token[0,20]
			user.name = auth.info.name
			user.image_url = auth.info.image
			user.role = "base" unless user.role?
		end
	end
	

	def self.new_with_session(params, session)
    	super.tap do |user|
			unless session["devise.google_data"].nil?
				puts session["devise.google_data"].to_hash
				data = session["devise.google_data"]
				user.email = data["info"]["email"]
				user.auth_provider = data["provider"]
				user.auth_uid = data["uid"]
				user.auth_token = Devise.friendly_token[0,20]
				user.name = data["info"]["name"]
				user.image_url = data["info"]["image"]
				user.role = "base"
				user.is_active = true
			end
	    end
	end

    def admin?
    	self.role == "admin"
    end

    def base?
    	self.role == "base"
    end

    def is_active?
    	self.is_active == true
    end

end
