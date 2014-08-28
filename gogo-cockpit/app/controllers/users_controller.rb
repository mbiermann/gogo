class UsersController < ApplicationController
	load_and_authorize_resource

	def index 
		@users = User.all
	end	

	def toggle
		@user = User.find(params[:id])
		@user.is_active = !@user.is_active
		@user.save() 
		redirect_to users_path
	end

	def destroy
		@user = User.find(params[:id])
		@user.destroy
		redirect_to users_path
	end

end
