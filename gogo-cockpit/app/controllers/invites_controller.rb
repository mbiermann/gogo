class InvitesController < ApplicationController
	load_and_authorize_resource

	def new
		@invite = Invite.new
	end

	def create
		@invite = Invite.new(invite_params)
		unless @invite.save()
			render "new"
		else
			send_invite(@invite)
			redirect_to invites_path
		end
	end

	def show
		# No need to fetch anything here. First acquire pin code on view.
	end

	def grant
		@invite = Invite.find(params[:id])
		unless @invite.nil?
			if @invite.pin == params[:pin]
				session[:invite_id] = @invite.id
				redirect_to user_omniauth_authorize_path("google_oauth2")
			else 
				@invalid_pin = true
				render "show"
			end
		else
			raise CanCan::AccessDenied.new("Not authorized!")
		end
	end

	def index
		@invites = Invite.all
	end

	def destroy
		Invite.find(params[:id]).destroy
		redirect_to invites_path
	end

	private

	def send_invite(invite)
		InviteMailer.invite_email(invite).deliver
	end

	def invite_params
		params.require(:invite).permit(:pin, :email)
	end

end
