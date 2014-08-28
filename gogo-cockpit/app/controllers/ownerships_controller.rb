class OwnershipsController < ApplicationController

	load_and_authorize_resource
	
	def index
		@ownerships = Ownership.find({:app_id => params[:app_id]})
	end

	def new 
		@app = App.find(params[:app_id])
	end

  	def create
		app = App.find(params[:app_id])
		params[:user_id] = current_user.id
		ownership = Ownership.create(ownership_params)
		redirect_to app_ownership_path(app, ownership)
	end

	def show
		@ownership = Ownership.find(params[:id])
	end

	def edit
		@ownership = Ownership.find(params[:id])
	end

	def update
		@ownership = Ownership.find(params[:id])
		if @ownership.update(ownership_params)
			redirect_to(@ownership)
		else
			render :edit
		end
	end

	def destroy
		@ownership = Ownership.find(params[:id])
		@ownership.destroy
		redirect_to :back
	end

	private

	def ownership_params
		params.require(:ownership).permit(:app_id, :user_id, :role)
	end

end
