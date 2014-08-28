class RegistrationsController < Devise::RegistrationsController

	def new
		if session[:invite_id].nil?
			raise CanCan::AccessDenied.new("Not authorized!")
		end
		invite = Invite.find(session[:invite_id])
		unless invite.nil?
			email = session["devise.google_data"]["info"]["email"]
			if email != invite.email
				redirect_to invite_path(invite), alert: "You must register with the email address you received the invite with."
				return
			end
			super
		else
			raise CanCan::AccessDenied.new("Not authorized!")
		end
	end

	def create
		if session[:invite_id].nil?
			raise CanCan::AccessDenied.new("Not authorized!")
		end
		invite = Invite.find(session[:invite_id])
		unless invite.nil?
			email = session["devise.google_data"]["info"]["email"]
			if email != invite.email
				redirect_to invite_path(invite), alert: "You must register with the email address you received the invite with."
			end
			invite.registered!
			invite.save
			super
		else
			raise CanCan::AccessDenied.new("Not authorized!")
		end
	end

	def update
		if session[:invite_id].nil?
			raise CanCan::AccessDenied.new("Not authorized!")
		end
		invite = Invite.find(session[:invite_id])
		unless invite.nil?
			email = session["devise.google_data"]["info"]["email"]
			if email != invite.email
				redirect_to invite_path(invite), alert: "You must register with the email address you received the invite with."
			end
			super
		else
			raise CanCan::AccessDenied.new("Not authorized!")
		end
	end

end